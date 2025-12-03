import { generateMessagesFromRow } from '../core/generateMessages';
import { Campaign, IngestRow, SkipReason } from '../core/types';

// Mock the scheduler helper
jest.mock('../core/scheduling', () => ({
  computeScheduledSendAt: jest.fn(),
}));

import { computeScheduledSendAt } from '../core/scheduling';

// Helper factories
function makeCampaign(partial: Partial<Campaign> = {}): Campaign {
  return {
    id: 'camp-1',
    name: 'Test Campaign',
    status: 'active',
    offsets: [1, 3],
    allowedHoursStart: '09:00',
    allowedHoursEnd: '17:00',
    timezone: 'America/Boise',
    sendDays: 'all',
    templateId: 'tmpl-1',
    templateVersion: 1,
    ...partial,
  };
}

function makeRow(partial: Partial<IngestRow> = {}): IngestRow {
  return {
    id: 'row-1',
    rowNumber: 1,
    patientId: 'patient-1',
    doctorId: 'doctor-1',
    contactPoint: '+15555550123',
    contactType: 'sms',
    appointmentDate: new Date('2025-01-10T12:00:00Z'),
    ...partial,
  };
}

const NOW = new Date('2025-01-01T00:00:00Z');

describe('generateMessagesFromRow', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });

  it('returns empty array for archived campaigns', () => {
    const campaign = makeCampaign({ status: 'archived' });
    const row = makeRow();

    const result = generateMessagesFromRow(campaign, row, { now: NOW });

    expect(result).toEqual([]);
    expect(computeScheduledSendAt).not.toHaveBeenCalled();
  });

  it('creates SKIPPED messages with CAMPAIGN_STATE for draft/paused campaigns', () => {
    const campaign = makeCampaign({
      status: 'draft',
      offsets: [1, 3],
    });
    const row = makeRow();

    const result = generateMessagesFromRow(campaign, row, { now: NOW });

    // Should create one SKIPPED per offset
    expect(result).toHaveLength(2);
    for (const msg of result) {
      expect(msg.status).toBe('SKIPPED');
      expect(msg.skipReason).toBe('CAMPAIGN_STATE');
      expect(msg.scheduledSendAt).toBeNull();
      expect(msg.campaignId).toBe(campaign.id);
      expect(msg.ingestRowId).toBe(row.id);
      expect(msg.contactPoint).toBe(row.contactPoint);
      expect(msg.contactType).toBe(row.contactType);
      expect(msg.personId).toBe(row.patientId);
      expect(msg.doctorId).toBe(row.doctorId);
      expect(msg.appointmentDate).toEqual(row.appointmentDate);
    }

    // No scheduling calls for draft/paused
    expect(computeScheduledSendAt).not.toHaveBeenCalled();
  });

  it('uses computeScheduledSendAt and creates SKIPPED message when it returns null', () => {
    const campaign = makeCampaign({
      status: 'active',
      offsets: [1],
    });
    const row = makeRow();

    (computeScheduledSendAt as jest.Mock).mockReturnValue({
      scheduledSendAt: null,
      skipReason: 'PAST_WINDOW' as SkipReason,
    });

    const result = generateMessagesFromRow(campaign, row, { now: NOW });

    expect(computeScheduledSendAt).toHaveBeenCalledTimes(1);
    expect(computeScheduledSendAt).toHaveBeenCalledWith({
      appointmentDate: row.appointmentDate,
      offsetDays: 1,
      now: NOW,
      campaign,
    });

    expect(result).toHaveLength(1);
    const msg = result[0];

    expect(msg.status).toBe('SKIPPED');
    expect(msg.skipReason).toBe('PAST_WINDOW');
    expect(msg.scheduledSendAt).toBeNull();
    expect(msg.offsetDays).toBe(1);
  });

  it('creates PENDING message when computeScheduledSendAt returns a valid date', () => {
    const campaign = makeCampaign({
      status: 'active',
      offsets: [1],
    });
    const row = makeRow();
    const scheduled = new Date('2025-01-09T10:00:00Z');

    (computeScheduledSendAt as jest.Mock).mockReturnValue({
      scheduledSendAt: scheduled,
      skipReason: null,
    });

    const result = generateMessagesFromRow(campaign, row, { now: NOW });

    expect(computeScheduledSendAt).toHaveBeenCalledTimes(1);

    expect(result).toHaveLength(1);
    const msg = result[0];

    expect(msg.status).toBe('PENDING');
    expect(msg.skipReason).toBeNull();
    expect(msg.scheduledSendAt).toEqual(scheduled);
    expect(msg.offsetDays).toBe(1);
    expect(msg.campaignId).toBe(campaign.id);
    expect(msg.ingestRowId).toBe(row.id);
  });

  it('handles mixed offsets where some skip and some are pending', () => {
    const campaign = makeCampaign({
      status: 'active',
      offsets: [1, 3],
    });
    const row = makeRow();

    (computeScheduledSendAt as jest.Mock)
      .mockReturnValueOnce({
        scheduledSendAt: null,
        skipReason: 'PAST_WINDOW' as SkipReason,
      })
      .mockReturnValueOnce({
        scheduledSendAt: new Date('2025-01-07T10:00:00Z'),
        skipReason: null,
      });

    const result = generateMessagesFromRow(campaign, row, { now: NOW });

    expect(computeScheduledSendAt).toHaveBeenCalledTimes(2);

    expect(result).toHaveLength(2);

    const msg0 = result[0];
    const msg1 = result[1];

    expect(msg0.status).toBe('SKIPPED');
    expect(msg0.skipReason).toBe('PAST_WINDOW');
    expect(msg0.offsetDays).toBe(1);

    expect(msg1.status).toBe('PENDING');
    expect(msg1.skipReason).toBeNull();
    expect(msg1.offsetDays).toBe(3);
  });
});
