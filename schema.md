# Patient Appointment Reminder System — Firestore Database Schema

## 1. Top-Level Collections
```
/companies/{companyId}
/users/{uid}
/templatesGlobal/{templateId}
/appSettings/{id}
/processingLocks/{entityId}
```

## 2. Company-Level Collections
```
/companies/{companyId}/campaigns/{campaignId}
/companies/{companyId}/messages/{messageId}
/companies/{companyId}/failuresData/{failureId}
/companies/{companyId}/failuresQueue/{failureId}
/companies/{companyId}/failuresSend/{failureId}
/companies/{companyId}/ingestFiles/{fileId}
/companies/{companyId}/ingestFiles/{fileId}/rows/{rowId}
/companies/{companyId}/templates/{templateId}
/companies/{companyId}/templates/{templateId}/versions/{versionId}
/companies/{companyId}/reports/{yyyymmdd}
/companies/{companyId}/rateLimits/{windowId}
/companies/{companyId}/settings
```

## 3. Schemas

### 3.1 Campaigns
```
name, status, nextFireDate, recurrence, lastFiredAt,
runHistory[], queryFilters{}, templateId, templateVersion,
createdAt, updatedAt
```

### 3.2 Messages
```
campaignId, status, scheduledSendAt, sentAt, deliveredAt, failedAt,
contactPoint, contactType, personId, doctorId, appointmentDate, calendarDay,
templateId, templateVersion, templateRender,
providerMessageId, providerStatus, providerResponse, statusHistory[],
dedupeHash, createdAt, updatedAt
```

### 3.3 Ingest Files
```
status, filename, totalRows, processedRows, validRows, invalidRows,
startedAt, completedAt, errorMessage
```

#### Rows
```
rowNumber, rawData{}, valid, messagesCreated, errorDetails{}
```

### 3.4 Failures
```
messageId, errorType, errorMessage, payload{}, createdAt
```

### 3.5 Templates
```
name, defaultVersionId, createdAt, updatedAt
```

#### Versions
```
versionId, bodySms, bodyEmail, subject, variables[], createdAt
```

### 3.6 Reports
```
uploaded, queued, sent, delivered, failed, retryCount, updatedAt
```

### 3.7 Settings
```
timezone, smsProvider, emailProvider, dailyLimit, userPreferences{}
```

### 3.8 Rate Limits
```
windowId, count, windowStart, expiresAt
```

## 4. Required Composite Indexes
- scheduledSendAt ASC, status ASC
- nextFireDate ASC, status ASC
- personId, doctorId, contactPoint, appointmentDate, calendarDay
- ingestFiles/{fileId}/rows: rowNumber ASC
