import { DateTime } from 'luxon';
import { Campaign } from './types';

function parseTimeToHoursMinutes(timeStr: string): { hour: number; minute: number } {
  const [hourStr, minuteStr] = timeStr.split(':');
  return {
    hour: Number(hourStr),
    minute: Number(minuteStr ?? '0'),
  };
}

export function computeScheduledSendAt(
  campaign: Campaign,
  appointmentDate: Date,
  offsetDays: number,
  now: Date
): Date | null {
  const tz = campaign.timezone;

  // convert inputs into campaign-local DateTimes
  const apptLocal = DateTime.fromJSDate(appointmentDate, { zone: tz });
  const nowLocal = DateTime.fromJSDate(now, { zone: tz });

  // 1) base = appointmentDate - offsetDays
  let base = apptLocal.minus({ days: offsetDays });

  // 2) if base < now → skip (PAST_WINDOW)
  if (base < nowLocal) {
    return null;
  }

  const { hour: startHour, minute: startMinute } = parseTimeToHoursMinutes(
    campaign.allowedHoursStart
  );
  const { hour: endHour, minute: endMinute } = parseTimeToHoursMinutes(
    campaign.allowedHoursEnd
  );

  // Helper: build same-day start/end boundaries
  const sameDayStart = (dt: DateTime) =>
    dt.set({ hour: startHour, minute: startMinute, second: 0, millisecond: 0 });
  const sameDayEnd = (dt: DateTime) =>
    dt.set({ hour: endHour, minute: endMinute, second: 0, millisecond: 0 });

  // 3) Clamp to allowed hours
  let scheduled = base;

  const startBoundary = sameDayStart(base);
  const endBoundary = sameDayEnd(base);

  if (scheduled < startBoundary) {
    // before window → move up to start of window (same day)
    scheduled = startBoundary;
  } else if (scheduled > endBoundary) {
    // after window → move to next day at allowedHoursStart
    scheduled = sameDayStart(base.plus({ days: 1 }));
  }

  // 4) Weekend bump (if weekdays-only)
  if (campaign.sendDays === 'weekdays-only') {
    // Luxon: 1=Mon .. 7=Sun
    while (scheduled.weekday === 6 || scheduled.weekday === 7) {
      // move to next day at window start
      scheduled = sameDayStart(scheduled.plus({ days: 1 }));
    }
  }

  // 5) If after clamping/weekend bump it's still < now → skip
  if (scheduled < nowLocal) {
    return null;
  }

  // 6) return JS Date in UTC (Firestore will store as timestamp)
  return scheduled.toJSDate();
}
