export type CampaignStatus = 'draft' | 'active' | 'paused' | 'archived';

export type SkipReason = 'CAMPAIGN_STATE' | 'PAST_WINDOW' | 'CLAMPED_PAST';

export interface Campaign {
  id: string;
  name: string;
  status: CampaignStatus;

  offsets: number[];               // [7, 3, 1]
  allowedHoursStart: string;       // "09:00"
  allowedHoursEnd: string;         // "19:00"
  timezone: string;                // "America/Boise"
  sendDays: 'all' | 'weekdays-only';

  rateLimit?: {
    maxPerMinute?: number | null;
  };

  patientLimits?: {
    maxPerDay?: number | null;
  };

  templateId: string;
  templateVersion?: string | number | null;
}

export interface IngestRow {
  id: string;                      // Firestore rowId
  rowNumber: number;
  patientId?: string | null;
  doctorId?: string | null;
  contactPoint: string;            // phone or email
  contactType: 'sms' | 'email' | 'voice';
  appointmentDate: Date;           // already parsed into JS Date
}

export type MessageStatus =
  | 'PENDING'
  | 'QUEUED'
  | 'SENDING'
  | 'SENT'
  | 'FAILED'
  | 'SKIPPED';

export interface GeneratedMessage {
  campaignId: string;
  ingestRowId: string;
  status: MessageStatus;
  skipReason: SkipReason | null;

  scheduledSendAt: Date | null;   // <-- allow null for SKIPPED
  offsetDays: number;

  contactPoint: string;
  contactType: 'sms' | 'email' | 'voice';
  personId?: string | null;
  doctorId?: string | null;
  appointmentDate: Date;
}
