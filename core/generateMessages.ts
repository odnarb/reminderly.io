import { Campaign, IngestRow, GeneratedMessage } from './types';

import { computeScheduledSendAt } from './scheduling';

interface GenerateMessagesOptions {
  now: Date;                       // injected for testability
  // later: patientDailyCountLookup, etc.
}

export function generateMessagesFromRow(
  campaign: Campaign,
  row: IngestRow,
  options: GenerateMessagesOptions
): GeneratedMessage[] {
  const { now } = options;

  // 1) Hard gate: archived generates nothing
  if (campaign.status === 'archived') {
    return [];
  }

  const isAutoSkippedByState =
    campaign.status === 'draft' || campaign.status === 'paused';

  const messages: GeneratedMessage[] = [];

  for (const offsetDays of campaign.offsets) {
    // If campaign isn't active, we still create a SKIPPED record
    if (isAutoSkippedByState) {
      messages.push({
        campaignId: campaign.id,
        ingestRowId: row.id,
        status: 'SKIPPED',
        skipReason: 'CAMPAIGN_STATE',

        scheduledSendAt: null,
        offsetDays,

        contactPoint: row.contactPoint,
        contactType: row.contactType,
        personId: row.patientId ?? null,
        doctorId: row.doctorId ?? null,
        appointmentDate: row.appointmentDate,
      });
      continue;
    }

    // Compute scheduling for active campaigns
    const { scheduledSendAt, skipReason } = computeScheduledSendAt({
      appointmentDate: row.appointmentDate,
      offsetDays,
      now,
      campaign,
    });

    // Scheduling-based skips
    if (!scheduledSendAt) {
      messages.push({
        campaignId: campaign.id,
        ingestRowId: row.id,
        status: 'SKIPPED',
        skipReason, // PAST_WINDOW or CLAMPED_PAST

        scheduledSendAt: null,
        offsetDays,

        contactPoint: row.contactPoint,
        contactType: row.contactType,
        personId: row.patientId ?? null,
        doctorId: row.doctorId ?? null,
        appointmentDate: row.appointmentDate,
      });
      continue;
    }

    // Happy path – ready to be picked up by queueing later
    messages.push({
      campaignId: campaign.id,
      ingestRowId: row.id,
      status: 'PENDING',
      skipReason: null,

      scheduledSendAt,
      offsetDays,

      contactPoint: row.contactPoint,
      contactType: row.contactType,
      personId: row.patientId ?? null,
      doctorId: row.doctorId ?? null,
      appointmentDate: row.appointmentDate,
    });
  }

  return messages;
}
