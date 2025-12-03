import { Campaign, SkipReason } from './types';

interface ComputeScheduledSendAtArgs {
  appointmentDate: Date;
  offsetDays: number;
  now: Date;
  campaign: Campaign;
}

interface ComputeScheduledSendAtResult {
  scheduledSendAt: Date | null;
  skipReason: SkipReason | null;
}

const DAY_MS = 24 * 60 * 60 * 1000;

function parseHourMinute(hhmm: string): { hour: number; minute: number } {
  const [h, m] = hhmm.split(':').map((x) => parseInt(x, 10));
  return { hour: h || 0, minute: m || 0 };
}

export function computeScheduledSendAt(
  args: ComputeScheduledSendAtArgs
): ComputeScheduledSendAtResult {
  const { appointmentDate, offsetDays, now, campaign } = args;

  // 1) base = appt - offsetDays (naively in server-local TZ)
  let base = new Date(appointmentDate.getTime() - offsetDays * DAY_MS);

  // 2) If base is already in the past, skip
  if (base.getTime() < now.getTime()) {
    return {
      scheduledSendAt: null,
      skipReason: 'PAST_WINDOW',
    };
  }

  // 3) Weekend bump if sendDays is 'weekdays-only'
  if (campaign.sendDays === 'weekdays-only') {
    let dow = base.getDay(); // 0=Sun, 6=Sat
    while (dow === 0 || dow === 6) {
      base = new Date(base.getTime() + DAY_MS);
      dow = base.getDay();
    }
  }

  // 4) Clamp to allowed hours
  const { hour: startHour, minute: startMinute } = parseHourMinute(
    campaign.allowedHoursStart
  );
  const { hour: endHour, minute: endMinute } = parseHourMinute(
    campaign.allowedHoursEnd
  );

  const year = base.getFullYear();
  const month = base.getMonth();
  const date = base.getDate();
  const currentHour = base.getHours();
  const currentMinute = base.getMinutes();

  let clamped = base;

  // If before start -> clamp up to startHour:startMinute
  if (
    currentHour < startHour ||
    (currentHour === startHour && currentMinute < startMinute)
  ) {
    clamped = new Date(
      year,
      month,
      date,
      startHour,
      startMinute,
      0,
      0
    );
  }

  // If after end -> clamp down to endHour:endMinute
  if (
    currentHour > endHour ||
    (currentHour === endHour && currentMinute > endMinute)
  ) {
    clamped = new Date(
      year,
      month,
      date,
      endHour,
      endMinute,
      0,
      0
    );
  }

  // 5) If clamped time is now in the past, skip
  if (clamped.getTime() < now.getTime()) {
    return {
      scheduledSendAt: null,
      skipReason: 'CLAMPED_PAST',
    };
  }

  // ✅ Happy path
  return {
    scheduledSendAt: clamped,
    skipReason: null,
  };
}
