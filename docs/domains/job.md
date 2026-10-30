# Job
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

Business-level page: `kjhc-docs:platforms/salesforce/data-model/job.md`. Framework: [architecture.md](../architecture.md).

## Classes

| Layer | Class | Path |
|---|---|---|
| Trigger | `KJ_Dispatch_JobTrigger` | `KJ_Dispatch/main/default/triggers/` |
| Controller | `KJ_Dispatch_Job` | `KJ_Dispatch/main/default/classes/controllers/` |
| Engine | `KJ_Engine_Job` | `KJ_Engine/main/default/classes/job/` |
| Model | None yet | |
| Metadata | `Job__c` (29 custom fields; Name is AutoNumber "Job Number") | `KJ_Model/main/default/objects/Job__c/` |

## Entry points
- **Trigger:** `KJ_Dispatch_JobTrigger`.
- **Called operations:** none.

## Automations
All in `KJ_Engine_Job`. On insert, a record that fails a validation is skipped for the rest. Validations stop at the first failure.

| Event | What happens |
|---|---|
| Before insert | **Validation:** `Parent_Account__c`, `Parent_Project__c` and `Customer_Property__c` are each required |
| Before insert | **Validation:** `Scheduled_End__c`, `Actual_End__c` and `Travel_End__c` must each be after their matching `*_Start__c` |
| Before insert | `Primary_Contact__c` = `Parent_Project__r.Primary_Contact__c`, falling back to `Parent_Account__r.Account_Primary_Contact__c`, when blank |
| Before insert | `Job_Sector__c` = `Parent_Project__r.Sector__c`, falling back to `Parent_Account__r.Account_Sector__c`, when blank |
| Before insert | `Service_Type__c` = `Parent_Project__r.Service_Type__c` when blank |
| Before insert | `Branch_Territory__c` = `Parent_Project__r.Branch_Territory__c`, falling back to `Parent_Account__r.Branch_Territory__c`, when blank |
| After insert, after update | `markLastServiceDate`: for Jobs with `Job_Status__c = 'Completed'` and `Actual_End__c` set, `Parent_Account__r.Last_Service_Date__c` = `Actual_End__c.date()` when later than the current value. One update per Account. |
| All other events | None. `onAfterDelete` holds only a `// disconnect related objects` comment. |

Every validation failure adds a HIGH `VALIDATION_ERROR` on the record.

## Relationships
- `Parent_Account__c` → Account (SetNull, relationship `Jobs`).
- `Parent_Project__c` → Project (Restrict).
- `Customer_Property__c` → Customer Property (Restrict).
- `Primary_Contact__c` → Contact (Restrict).

## Tests

| Test class | Methods |
|---|---|
| `KJ_Dispatch_Job_Test` | `receive_InvalidPackages_FailPath`, `receive_EmptyTriggerContext_HappyPath`, `insert_FillsBlanks_HappyPath`, `insert_KeepsProvidedValues_HappyPath`, `insert_Validation_MixedPath`, `markLastServiceDate_InsertAndUpdate_HappyPath`, `jobTrigger_BulkBatch_HappyPath` |

## Status
Stable. No model class.

## Gaps
- Validations run on insert only.
- `'Completed'` is hardcoded. There's no `JobStatus` enum in `KJ_Model_Picklist`.
- `Parent_Account__c` is required by the engine, but its lookup is SetNull. Deleting the Account is blocked anyway by `KJ_Engine_Account.onBeforeDelete`.
- `markLastServiceDate` never moves `Last_Service_Date__c` backwards, for example when a Job's `Actual_End__c` is corrected to an earlier date.
- `TODO(slate): Should Parent_Account__c be filled from Parent_Project__r.Parent_Account__c instead of required?`
