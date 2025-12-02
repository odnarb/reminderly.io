# Patient Appointment Reminder System — Firestore Database Schema (v2)

## 1. Top-Level Collections

```text
/companies/{companyId}
/users/{uid}
/templatesGlobal/{templateId}
/appSettings/{id}
/processingLocks/{entityId}
```

- **/companies/{companyId}** – root for all tenant-scoped data
- **/users/{uid}** – application users (linked to Firebase Auth)
- **/templatesGlobal/{templateId}** – shared/global templates (optional)
- **/appSettings/{id}** – global app configuration
- **/processingLocks/{entityId}** – TTL-based processing locks for idempotency

---

## 2. Company-Level Collections

```text
/companies/{companyId}/campaigns/{campaignId}
/companies/{companyId}/messages/{messageId}
/companies/{companyId}/failuresData/{failureId}
/companies/{companyId}/failuresQueue/{failureId}
/companies/{companyId}/failuresSend/{failureId}
/companies/{companyId}/ingestFiles/{fileId}
/companies/{companyId}/ingestFiles/{fileId}/rows/{rowId}
/companies/{companyId}/templates/{templateId}
/companies/{companyId}/templates/{templateId}/versions/{versionId}
/companies/{companyId}/summaries/{yyyymmdd}
/companies/{companyId}/rateLimits/{windowId}
/companies/{companyId}/settings
```

Notes:

- `summaries` here matches the architecture doc terminology (daily summaries).
- `rateLimits` is used for per-company/campaign rate window tracking.
- `settings` holds company-level defaults (timezone, provider, default limits).

---

## 3. Schemas

### 3.1 Campaigns

**Path:**  
`/companies/{companyId}/campaigns/{campaignId}`

```text
name: string

status: string            // 'draft' | 'active' | 'paused' | 'archived'

nextFireDate: timestamp   // when the campaign should next be evaluated
recurrence: object|null   // optional recurrence rules, if used
lastFiredAt: timestamp|null
runHistory: array<object> // optional history of campaign runs

offsets: array<number>    // e.g. [7, 3, 1] (days before appointment)

allowedHoursStart: string // "HH:MM" (campaign-local time)
allowedHoursEnd: string   // "HH:MM"

timezone: string          // e.g. "America/Boise"

sendDays: string          // 'all' | 'weekdays-only'

rateLimit: object         // send speed limits
  - maxPerMinute: number|null  // null or 0 = unlimited

patientLimits: object     // per-patient limits (campaign-level)
  - maxPerDay: number|null     // null = disabled

templateId: string        // single offset-aware template
templateVersion: string|number|null // optional snapshot of version used

queryFilters: object|null // optional advanced targeting (future use)

createdAt: timestamp
updatedAt: timestamp
```

---

### 3.2 Messages

**Path:**  
`/companies/{companyId}/messages/{messageId}`

```text
campaignId: string

status: string            // 'QUEUED' | 'SENDING' | 'SENT' | 'FAILED' | 'SKIPPED'
skipReason: string|null   // 'PAST_WINDOW' | 'PATIENT_DAILY_LIMIT' | 'CAMPAIGN_PAUSED' |
                          // 'CAMPAIGN_DRAFT' | 'INVALID_CONTACT' | etc.

scheduledSendAt: timestamp
sentAt: timestamp|null
deliveredAt: timestamp|null
failedAt: timestamp|null

offsetDays: number        // 7, 3, 1 etc (which offset generated this message)

contactPoint: string      // phone number or email
contactType: string       // 'sms' | 'email' | 'voice'

personId: string|null
doctorId: string|null
appointmentDate: timestamp|null
calendarDay: string|null  // 'YYYY-MM-DD' in campaign timezone

templateId: string|null
templateVersion: string|number|null
templateRender: object|null  // snapshot of rendered body/subject if desired

providerMessageId: string|null
providerStatus: string|null
providerResponse: object|null

statusHistory: array<object> // [{ status, at, reason? }, ...]

dedupeHash: string|null      // used for duplicate detection

createdAt: timestamp
updatedAt: timestamp
```

---

### 3.3 Ingest Files

**Path:**  
`/companies/{companyId}/ingestFiles/{fileId}`

```text
status: string              // 'pending' | 'processing' | 'complete' |
                            // 'complete-with-errors' | 'failed'

filename: string
totalRows: number
processedRows: number
validRows: number
invalidRows: number

campaignId: string          // campaign this ingest is attached to

startedAt: timestamp|null
completedAt: timestamp|null
errorMessage: string|null

createdAt: timestamp
updatedAt: timestamp
```

#### Ingest Rows

**Path:**  
`/companies/{companyId}/ingestFiles/{fileId}/rows/{rowId}`

```text
rowNumber: number
rawData: object             // original parsed CSV row
valid: boolean
messagesCreated: number     // how many messages were generated from this row
errorDetails: object|null   // validation errors, parsing errors, etc.

createdAt: timestamp
updatedAt: timestamp
```

---

### 3.4 Failures

#### failuresData

**Path:**  
`/companies/{companyId}/failuresData/{failureId}`

Validation / ingest-level data failures (bad input rows, etc.).

```text
source: string              // 'ingest' | 'mapping' | etc.
fileId: string|null
rowId: string|null
rowNumber: number|null

errorType: string
errorMessage: string
payload: object|null        // raw data that failed

createdAt: timestamp
```

#### failuresQueue

**Path:**  
`/companies/{companyId}/failuresQueue/{failureId}`

Failures during queueing / message preparation.

```text
messageId: string|null
errorType: string
errorMessage: string
payload: object|null        // message or transformed payload

createdAt: timestamp
```

#### failuresSend

**Path:**  
`/companies/{companyId}/failuresSend/{failureId}`

Send/delivery-related failures.

```text
messageId: string|null
errorType: string
errorMessage: string
providerResponse: object|null
attemptNumber: number|null

createdAt: timestamp
```

---

### 3.5 Templates (Company-Scoped)

**Path:**  
`/companies/{companyId}/templates/{templateId}`

```text
name: string
defaultVersionId: string
createdAt: timestamp
updatedAt: timestamp
```

#### Template Versions

**Path:**  
`/companies/{companyId}/templates/{templateId}/versions/{versionId}`

```text
versionId: string
bodySms: string|null
bodyEmail: string|null
subject: string|null

variables: array<string>  // ['patientName', 'appointmentDateTime', 'offsetDays', ...]

createdAt: timestamp
```

> Note: For this system, **campaigns use a single offset-aware template**, and the template
> engine receives `offsetDays` as part of the rendering context.

---

### 3.6 Global Templates (Optional)

**Path:**  
`/templatesGlobal/{templateId}`

```text
name: string
defaultVersionId: string
createdAt: timestamp
updatedAt: timestamp
```

**Path:**  
`/templatesGlobal/{templateId}/versions/{versionId}`

```text
versionId: string
bodySms: string|null
bodyEmail: string|null
subject: string|null
variables: array<string>
createdAt: timestamp
```

---

### 3.7 Daily Summaries

**Path:**  
`/companies/{companyId}/summaries/{yyyymmdd}`

```text
date: string               // 'YYYY-MM-DD'
uploaded: number
queued: number
sent: number
delivered: number
failed: number
skipped: number            // total SKIPPED messages (any reason)
retryCount: number

updatedAt: timestamp
```

> These documents back the reporting dashboard; they are updated incrementally by
> background functions instead of querying the full messages collection.

---

### 3.8 Settings (Company Defaults)

**Path:**  
`/companies/{companyId}/settings`

```text
timezone: string                // default campaign timezone
smsProvider: string|null
emailProvider: string|null

defaultCampaignLimits: object   // defaults for new campaigns
  - rateLimitMaxPerMinute: number|null
  - patientMaxPerDay: number|null

userPreferences: object|null    // per-company dashboard preferences, etc.

createdAt: timestamp
updatedAt: timestamp
```

---

### 3.9 Rate Limits

**Path:**  
`/companies/{companyId}/rateLimits/{windowId}`

Used to enforce per-company or per-campaign rate windows, if needed.

```text
windowId: string           // e.g. 'company:{companyId}:2025-01-01T12:30'
scope: string              // 'company' | 'campaign'
companyId: string
campaignId: string|null

count: number              // number of sends in this window
windowStart: timestamp
expiresAt: timestamp       // TTL for automatic cleanup
```

---

### 3.10 Processing Locks

**Path:**  
`/processingLocks/{entityId}`

```text
entityId: string           // e.g. 'campaign:{campaignId}' or 'file:{fileId}'
ownerId: string|null       // optional worker id
lockedAt: timestamp
expiresAt: timestamp       // Firestore TTL for stale lock cleanup
```

---

## 4. Required Composite Indexes

To support the main query patterns, define these composite indexes:

1. **Messages – send scheduler**
   ```text
   collection: /companies/{companyId}/messages
   fields:
     - scheduledSendAt: ASC
     - status: ASC
   ```

2. **Campaigns – campaign scheduler**
   ```text
   collection: /companies/{companyId}/campaigns
   fields:
     - nextFireDate: ASC
     - status: ASC
   ```

3. **Messages – duplicate detection**
   ```text
   collection: /companies/{companyId}/messages
   fields:
     - personId: ASC
     - doctorId: ASC
     - contactPoint: ASC
     - appointmentDate: ASC
     - calendarDay: ASC
   ```

4. **Ingest rows – paging**
   ```text
   collection: /companies/{companyId}/ingestFiles/{fileId}/rows
   fields:
     - rowNumber: ASC
   ```

---

# ✅ Notes

- This schema reflects the **campaign = smart, ingest = dumb** model.
- It encodes:
  - Campaign offsets (`offsets`)
  - Time windows + timezone (`allowedHoursStart/End`, `timezone`, `sendDays`)
  - Per-campaign send rate (`rateLimit.maxPerMinute`)
  - Per-patient daily cap (`patientLimits.maxPerDay`)
  - Message-level skip reasons + offsets (`status`, `skipReason`, `offsetDays`)
- It aligns with the **architecture doc (v2)** you’re using for implementation.
