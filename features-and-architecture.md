
# 📘 **Patient Appointment Reminder System — Architecture Document**

## Overview
This system automates appointment reminders for clinics by supporting:

- Campaign scheduling
- Data ingest
- Message mapping & templating
- Message queueing
- Delivery sending (SMS/Email)
- Delivery receipts
- Failures + retry
- Reporting + dashboards
- Fully multi-tenant isolation

The system uses **Google Cloud Platform (GCP)** and **Firestore** as the primary components.

---

# 1. **Architecture Summary**

### **Core GCP Components**
- **Cloud Scheduler** — triggers campaign/message checks every 5 min
- **Cloud Functions** — queueing, sending, ingest, and reporting
- **Pub/Sub** — async scaling for sending and queueing
- **Firestore** — campaign, message, failure, ingest, summary storage
- **Cloud Storage** — raw file uploads
- **Firebase Auth** — dashboard authentication

Optional future expansion:
- Auth0 SSO  
- BigQuery export  

---

# 2. **Multi-Tenant Data Model**

### All data is stored under company-scoped paths:
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
- All authenticated users carry:
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
- Find campaigns with `nextFireDate <= now()` and `status = "ready"`

### **Message Scheduler**
- Find queued messages with `scheduledSendAt <= now()`

---

# 5. **Idempotency Strategy**

Uses status-based locking with TTL-assisted lock docs.

```
status: ready | processing | complete | failed
processingAt: timestamp
```

Additional TTL lock doc:
```
/processingLocks/{entityId}
```

---

# 6. **Data Ingest (Row-by-Row Partial Load)**

- File uploaded → ingestFile doc created
- Rows validated
- Valid rows saved
- Invalid rows → failuresData collection
- File ends as:
  - complete
  - complete-with-errors
  - failed

---

# 7. **Message Mapping**

/- Flexible fields
- Trim/normalize
- Snapshot template version at send time
- Retries use **latest** template version

---

# 8. **Message Queueing Pipeline**

- Special char check
- Phone/email check
- Dedupe check
- Template merge

Failures → failuresQueue.

---

# 9. **Duplicate Logic**

Duplicate if:
1. personId
2. doctorId
3. contactPoint
4. appointmentDate
5. calendarDay

Composite index required.

---

# 10. **Sending Architecture**

- Pub/Sub scaled sending
- Per-company rate limits
- TTL rate-window docs

---

# 11. **Delivery Receipts**

Webhook updates message doc:
```
status
providerStatus
providerMessageId
providerResponse
statusHistory
```

Idempotent timestamp-based.

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

Daily totals:
- uploaded
- queued
- sent
- delivered
- failures

Dashboard uses summaries (fast, cheap).

---

# 14. **Dashboard Features**

- react app on cloud run
- upload data
- review data
- manage campaigns
- preview templates
- view messages
- view failures
- reporting dashboard

---

# 15. **Future Roadmap**

- Auth0 / SSO
- BigQuery analytics
- AI cleanup pipelines
- Full REST API

---

# 16. **File Architecture**

/
├── core/                          # Shared logic used across functions + Cloud Run
│   ├── db/
│   ├── validation/
│   ├── templating/
│   ├── queue/
│   ├── util/
│   └── index.js
│
├── functions/                     # Cloud Functions bundles
│   ├── send/
│   │   ├── index.js
│   │   ├── package.json
│   │   └── core (copied from ../core at build time)
│   ├── queue/
│   │   ├── index.js
│   │   ├── package.json
│   │   └── core (copied from ../core at build time)
│   ├── ingest/
│   │   ├── index.js
│   │   ├── package.json
│   │   └── core (copied from ../core at build time)
│   ├── report/
│   │   ├── index.js
│   │   ├── package.json
│   │   └── core (copied from ../core at build time)
│   └── shared/                    # (Optional) shared files symlinked or copied in
│
├── src/                           # Cloud Run app
│   ├── routes/
│   ├── middleware/
│   ├── controllers/
│   ├── services/
│   ├── health/                    # health checks
│   ├── index.js                   # entry into cloudrun
│   └── ...
│
├── package.json
├── .gitignore
│
├── .env.example                   # Example environment variables
│
├── deploy/                        # Infra + deployment scripts
│   ├── cloudbuild-dev.yaml
│   ├── cloudbuild-prod.yaml
│   ├── terraform/                 # (Optional but recommended)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── scripts/                   # utility scripts (deploy, build, prune)
│
├── .github/
│   └── workflows/
│       ├── dev.yml
│       └── prod.yml
│
├── tests/                         # Jest or Vitest test suite
│   ├── unit/
│   ├── integration/
│   └── mocks/
│
├── docs/                          # Architecture/DB/README documents
│
└── README.md


# 🎉 End of Document
