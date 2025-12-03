// scheduling.test.ts

import { computeScheduledSendAt } from '../core/scheduling';
import { Campaign } from '../core/types';

function makeCampaign(partial: Partial<Campaign> = {}): Campaign {
  return {
    id: 'camp-1',
    name: 'Test Campaign',
    status: 'active',
    offsets: [1],
    allowedHoursStart: '09:00',
    allowedHoursEnd: '17:00',
    timezone: 'America/Boise',
    sendDays: 'all',
    templateId: 'tmpl-1',
    templateVersion: 1,
    ...partial,
  };
}

describe('computeScheduledSendAt', () => {
  const NOW = new Date('2025-01-01T08:00:00Z');

  it('returns PAST_WINDOW when base is before now', () => {
    const appointmentDate = new Date('2025-01-02T00:00:00Z');
    const campaign = makeCampaign();

    const { scheduledSendAt, skipReason } = computeScheduledSendAt({
      appointmentDate,
      offsetDays: 2, // 2nd - 2 days = Dec 31 < NOW (Jan 1)
      now: NOW,
      campaign,
    });

    expect(scheduledSendAt).toBeNull();
    expect(skipReason).toBe('PAST_WINDOW');
  });

  it('returns a future date when base is after now', () => {
    const appointmentDate = new Date('2025-01-10T12:00:00Z');
    const campaign = makeCampaign();

    const { scheduledSendAt, skipReason } = computeScheduledSendAt({
      appointmentDate,
      offsetDays: 3,
      now: NOW,
      campaign,
    });

    expect(skipReason).toBeNull();
    expect(scheduledSendAt).not.toBeNull();

    const d = scheduledSendAt!;
    // rough check: should be a few days after NOW
    expect(d.getTime()).toBeGreaterThan(NOW.getTime());
  });

  it('clamps earlier times up to allowedHoursStart', () => {
    const appointmentDate = new Date('2025-01-10T06:00:00Z');
    const campaign = makeCampaign({
      allowedHoursStart: '09:00',
      allowedHoursEnd: '17:00',
    });

    const { scheduledSendAt, skipReason } = computeScheduledSendAt({
      appointmentDate,
      offsetDays: 1,
      now: NOW,
      campaign,
    });

    expect(skipReason).toBeNull();
    expect(scheduledSendAt).not.toBeNull();

    const d = scheduledSendAt!;
    expect(d.getHours()).toBeGreaterThanOrEqual(9);
  });

    it('returns CLAMPED_PAST when clamped time is before now', () => {
    // Use local times (no "Z") so everything is in the same timezone basis
    const now = new Date('2025-01-01T16:00:00');           // 4:00 PM local
    const appointmentDate = new Date('2025-01-01T18:00:00'); // 6:00 PM local

    const campaign = makeCampaign({
        allowedHoursStart: '06:00',
        allowedHoursEnd: '13:00', // window 06:00–13:00
    });

    const { scheduledSendAt, skipReason } = computeScheduledSendAt({
        appointmentDate,
        offsetDays: 0,
        now,
        campaign,
    });

    // Explanation:
    // base = 18:00 (appointment - 0 days) -> after now (16:00) so not PAST_WINDOW
    // clamp -> 13:00 (end of allowed window)
    // 13:00 < 16:00 => CLAMPED_PAST

    expect(scheduledSendAt).toBeNull();
    expect(skipReason).toBe('CLAMPED_PAST');
    });

});
