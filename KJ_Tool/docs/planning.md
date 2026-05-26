KJ_Tool/main/default/classes/
│
├── logging/
│   ├── Logger.cls                ← already have
│   ├── LogEntry.cls              ← already have
│   └── LogLevel.cls              ← enum: DEBUG, INFO, WARN, ERROR, FATAL
│
├── formatting/
│   ├── Formatter.cls             ← already have
│   ├── DateFormatter.cls         ← all date/time display logic
│   └── CurrencyFormatter.cls     ← HVAC estimates, billing amounts
│
├── validation/
│   ├── Validator.cls             ← chainable validation engine
│   ├── ValidationRule.cls        ← interface — one rule, one class
│   └── ValidationResult.cls      ← holds pass/fail + messages
│
├── querying/
│   ├── QueryBuilder.cls          ← programmatic SOQL builder
│   └── QueryFilter.cls           ← reusable filter conditions
│
├── errors/
│   ├── AppException.cls          ← base custom exception
│   ├── ValidationException.cls
│   ├── IntegrationException.cls
│   └── NotFoundException.cls
│ 
├── collections/
│   ├── CollectionUtils.cls       ← filter, group, pluck, dedupe lists
│   └── MapUtils.cls              ← safe gets, merges, inversions
│
├── http/
│   ├── HttpRequestBuilder.cls    ← fluent builder for callouts
│   ├── HttpResponseParser.cls    ← normalize any external response
│   └── RetryHandler.cls          ← retry logic with backoff
│
├── context/
    ├── Origin.cls
│   ├── TriggerContext.cls        ← standardized trigger state
│   ├── UserContext.cls           ← current user, profile, permissions
│   └── OrgContext.cls            ← org-wide settings, custom metadata
│
├── constants/
│   └── Constants.cls             ← org-wide enums and static values
│
├── utils/
│   ├── StringUtils.cls
│   ├── DateUtils.cls
│   ├── NumberUtils.cls
│   └── IdUtils.cls               ← safe ID casting, type detection
│
└── testing/
    ├── TestDataFactory.cls       ← already have
    ├── TestContext.cls           ← sets up mock users, settings for tests
    └── MockHttpCallout.cls       ← mock external responses in tests