import { Campaign, IngestRow, GeneratedMessage } from './types';

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

  // 1) Campaign state gate
  if (campaign.status === 'archived') {
    return []; // ingest should probably be blocked before this
  }

  // For draft/paused we still generate but mark as SKIPPED later.
  const isAutoSkippedByState =
    campaign.status === 'draft' || campaign.status === 'paused';

  const messages: GeneratedMessage[] = [];

  for (const offsetDays of campaign.offsets) {
    // TODO: implement:
    // - base = appt - offset
    // - if base < now => skip PAST_WINDOW
    // - clamp to allowedHours
    // - weekend bump if weekdays-only
    // - if clamped < now => skip
    const scheduledSendAt = computeScheduledSendAt(
      campaign,
      row.appointmentDate,
      offsetDays,
      now
    );

    if (!scheduledSendAt) {
      // e.g. PAST_WINDOW case; we just don't create a message at all
      continue;
    }

    const baseMessage: GeneratedMessage = {
      campaignId: campaign.id,
      ingestRowId: row.id,
      status: isAutoSkippedByState ? 'SKIPPED' : 'QUEUED',
      skipReason: isAutoSkippedByState
        ? (campaign.status === 'draft'
            ? 'CAMPAIGN_DRAFT'
            : 'CAMPAIGN_PAUSED')
        : null,

      scheduledSendAt,
      offsetDays,

      contactPoint: row.contactPoint,
      contactType: row.contactType,
      personId: row.patientId ?? null,
      doctorId: row.doctorId ?? null,
      appointmentDate: row.appointmentDate,
    };

    messages.push(baseMessage);
  }

  return messages;
}

// Stub for now — next step we fill this in
function computeScheduledSendAt(
  campaign: Campaign,
  appointmentDate: Date,
  offsetDays: number,
  now: Date
): Date | null {
  // placeholder, we’ll wire the full rules next
  return appointmentDate; // just to have a compile-happy stub
}
