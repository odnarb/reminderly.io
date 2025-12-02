# 📘 **Patient Appointment Reminder System — Architecture Document**

## Overview
This system automates appointment reminders for clinics by supporting:

- Campaign scheduling
- Data ingest
- Message mapping & templating
- Message queueing
- Delivery sending (SMS/Email/Voice)
- Delivery receipts
- Failures + retry
- Reporting + dashboards
- Fully multi-tenant isolation

The system uses **Google Cloud Platform (GCP)** and **Firestore** as the primary components.

---

# 1. **Architecture Summary**

### **Core GCP Components**
- **Cloud Scheduler** — triggers campaign/message checks every 5 min
- **Cloud Functions** — queueing, sending, ingest, reporting
- **Pub/Sub** — async scale-out for queueing/sending
- **Firestore** — campaigns, messages, failures, ingests, summaries
- **Cloud Storage** — raw file uploads
- **Firebase Auth** — dashboard authentication

Optional future expansion:
- Auth0 SSO
- BigQuery export

---

# 2. **Multi-Tenant Data Model**

All data is stored under company-scoped paths:

```
/companies/{companyId}/campaigns/{campaignId}
/companies/{companyId}/messages/{messageId}
/companies/{companyId}/failuresData/{failureId}
/companies/{companyId}/failuresQueue/{failureId}
/companies/{companyId}/failuresSend/{failureId}
/companies/{companyId}/ingestFiles/{fileId}
/companies/{companyId}/summaries/{YYYY-MM-DD}
/companies/{companyId}/settings
```

Global collections:
```
/users/{uid}
/templatesGlobal/{id}
/appSettings/{id}
```

---

# 3. **Security Model**

### **Authentication**
- Firebase Auth
- Auth token stores:
  - `companyId`
  - `role`

### **Authorization**
```javascript
match /companies/{companyId}/{collection=**}/{docId} {
  allow read, write: if
    request.auth != null &&
    request.auth.token.companyId == companyId &&
    request.auth.token.role in ['admin', 'staff'];
}
```

---

# 4. **Scheduler Architecture**

### **Campaign Scheduler**
- Every 5 minutes:
  - Find campaigns with `nextFireDate <= now()`
  - Queue campaign’s batch generation

### **Message Scheduler**
- Every 5 minutes:
  - Find `QUEUED` messages with `scheduledSendAt <= now()`
  - Throttle per campaign
  - Send via Pub/Sub

---

# 5. **Idempotency Strategy**

Status-based locking with optional lock TTL docs:

```
status: ready | processing | complete | failed
processingAt: timestamp
```

TTL-based lock doc:
```
/processingLocks/{entityId}
```

---

# 6. **Data Ingest (Row-by-Row Partial Load)**

- File uploaded → `ingestFile` doc created
- Rows validated
- Valid rows saved
- Invalid rows → failuresData
- File ends as:
  - `complete`
  - `complete-with-errors`
  - `failed`

Ingest data is **dumb**: appointment details & patient info only.

---

# 7. **Message Mapping**

- Flexible field mapping
- Trim/normalize data
- Template snapshot evaluated at message generation
- Retries use **latest** template version

---

# 8. **Message Queueing Pipeline**

Per row:
- Special char check
- Phone/email validation
- Duplicate check
- Template merge
- Final message queued or skipped
- Failures → failuresQueue

---

# 9. **Duplicate Logic**

Message considered duplicate if:
1. `personId`
2. `doctorId`
3. `contactPoint`
4. `appointmentDate`
5. `calendarDay`

Composite index required.

---

# 10. **Sending Architecture**

- Pub/Sub scalable sending
- Per-company & per-campaign rate limits
- TTL docs to enforce rate windows

---

# 11. **Delivery Receipts**

Webhook → updates:

```
status
providerStatus
providerMessageId
providerResponse
statusHistory
```

Idempotent via timestamps.

---

# 12. **Failure Handling (Three Buckets)**

```
failuresData
failuresQueue
failuresSend
```

---

# 13. **Reporting Model (Daily Summaries)**

```
/companies/{companyId}/summaries/{YYYY-MM-DD}
```

Daily:
- uploaded
- queued
- sent
- delivered
- failures

Dashboard consumes summaries (fast, cheap).

---

# 14. **Dashboard Features**

- React app on Cloud Run
- Uploading + ingest previews
- Review data
- Manage campaigns
- Preview templates
- Message viewer
- Failure viewer
- Reporting dashboard

---

# 15. **Future Roadmap**

- Auth0 / full SSO
- BigQuery analytics
- Automated cleanup pipelines
- Full REST API

---

# 16. **File Architecture**

```
/
├── core/                          # Shared logic for functions + Cloud Run
│   ├── db/
│   ├── validation/
│   ├── templating/
│   ├── queue/
│   ├── util/
│   └── index.js
│
├── functions/                     # GCP Cloud Functions
│   ├── send/
│   ├── queue/
│   ├── ingest/
│   ├── report/
│   └── shared/
│
├── src/                           # Cloud Run app
│   ├── routes/
│   ├── middleware/
│   ├── controllers/
│   ├── services/
│   ├── health/
│   └── index.js
│
├── deploy/
│   ├── cloudbuild-dev.yaml
│   ├── cloudbuild-prod.yaml
│   └── terraform/
│
├── tests/
├── docs/
└── README.md
```

---

# 17. **Campaign Configuration & Reminder Logic** *(Conversation Decisions Integrated)*

## **Campaign = Smart**
Campaign defines:
- `offsets`: e.g., `[7,3,1]`
- `allowedHoursStart` / `allowedHoursEnd`
- `timezone`
- `sendDays = "all" | "weekdays-only"`
- `rateLimit.maxPerMinute`
- `patientLimits.maxPerDay`
- Template: **single template**, offset-aware
- State: `draft | active | paused | archived`

## **Ingest = Dumb**
A file ingest **does not create a campaign**.
It only attaches data to an **existing** campaign and generates messages that follow campaign rules.

---

# 18. **Campaign States**

### `draft`
- Ingest allowed
- All generated messages → `SKIPPED:CAMPAIGN_DRAFT`

### `active`
- Normal  
- Ingest creates queued messages based on rules

### `paused`
- Ingest allowed
- All messages → `SKIPPED:CAMPAIGN_PAUSED`

### `archived`
- Ingest **rejected**

---

# 19. **Reminder Timestamp Generation Flow**

For each appointment row:

### 1. **Compute base timestamp**
`base = appointmentDate - offsetDays` (in campaign timezone)

### 2. **If base < now → SKIP (PAST_WINDOW)**

### 3. **Clamp to allowed hours**
- Before allowed window → set to `allowedHoursStart`
- After allowed window → set to `allowedHoursStart` **next day**

### 4. **Weekend bump (if weekdays-only)**
- Sat/Sun → move to Monday @ `allowedHoursStart`

### 5. **If new time < now → SKIP**

### 6. **Per-patient cap**
- If messages today (campaign TZ) ≥ `maxPerDay`
  → `SKIPPED:PATIENT_DAILY_LIMIT`

### 7. **Create QUEUED message**
```
status: QUEUED
scheduledSendAt: computedTimestamp
offsetDays: X
skipReason: null
```

### 8. **Send-time throttle**
Scheduler:
- Finds `scheduledSendAt <= now`
- Sends ≤ `rateLimit.maxPerMinute` per campaign
- Updates status to SENT/FAILED

---

# 🎉 End of Document
