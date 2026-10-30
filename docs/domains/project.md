# Project
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

Business-level page: `kjhc-docs:platforms/salesforce/data-model/project.md`. Framework: [architecture.md](../architecture.md). A Project fills the role an Opportunity would (`kjhc-docs:decisions/0001-project-replaces-opportunity.md`).

## Classes

| Layer | Class | Path |
|---|---|---|
| Trigger | `KJ_Dispatch_ProjectTrigger` | `KJ_Dispatch/main/default/triggers/` |
| Controller | `KJ_Dispatch_Project` | `KJ_Dispatch/main/default/classes/controllers/` |
| Engine | `KJ_Engine_Project` | `KJ_Engine/main/default/classes/project/` |
| Model | None yet | |
| Metadata | `Project__c` (23 custom fields; Name is AutoNumber "Project Number") | `KJ_Model/main/default/objects/Project__c/` |

## Entry points
- **Trigger:** `KJ_Dispatch_ProjectTrigger`.
- **Called operations:** none.

## Automations
All in `KJ_Engine_Project`, before insert. The validations run first, and a failing record is skipped for the rest.

| Event | What happens |
|---|---|
| Before insert | **Validation:** `Scheduled_End_Date__c` must not be before `Scheduled_Start_Date__c` (when both are set). Failure adds a HIGH `VALIDATION_ERROR`. |
| Before insert | **Validation:** `Actual_End_Date__c` must not be before `Actual_Start_Date__c` (when both are set). Failure adds a HIGH `VALIDATION_ERROR`. |
| Before insert | `Primary_Contact__c` = `Parent_Account__r.Account_Primary_Contact__c` when blank |
| Before insert | `Sector__c` = `Customer_Property__r.Property_Sector__c`, falling back to `Parent_Account__r.Account_Sector__c`, when blank |
| Before insert | `Branch_Territory__c` = `Parent_Account__r.Branch_Territory__c` when blank |
| Before insert | `Record_Origin__c` = `'KJHC Salesforce V2'` when blank |
| Before insert | `Actual_Start_Date__c` = today when `Project_Status__c = 'In Progress'` and it's blank |
| Before insert | `Actual_End_Date__c` = today when `Project_Status__c = 'Completed'` and it's blank |
| Before insert | `Project_Name__c` = `<Property street> - <Scheduled_Start_Date__c>` when blank and both values exist (commit `569f35d`) |
| All other events | None. `onAfterDelete` holds only a `// disconnect related objects` comment. |

## Relationships
- `Parent_Account__c` → Account (SetNull, relationship `Projects`).
- `Primary_Contact__c` → Contact (SetNull).
- `Customer_Property__c` → Customer Property (SetNull).
- `Originating_Lead__c` → Lead (SetNull). Being removed (`kjhc-docs:decisions/0002-retire-lead-object.md`).
- Child: `Job__c.Parent_Project__c` (Restrict).

## Tests

| Test class | Methods |
|---|---|
| `KJ_Dispatch_Project_Test` | `receive_InvalidPackages_FailPath`, `receive_EmptyTriggerContext_HappyPath`, `insert_FillsBlanks_HappyPath`, `insert_KeepsProvidedValues_HappyPath`, `insert_DateValidation_MixedPath`, `projectTrigger_BulkBatch_HappyPath` |

## Status
Stable. No model class. Financial fields are planned.

## Gaps
- Status stamps and validation run on insert only. Moving a Project to In Progress or Completed later doesn't stamp the dates.
- `'In Progress'` and `'Completed'` are hardcoded. There's no `ProjectStatus` enum in `KJ_Model_Picklist`.
- The `primaryContacts` query in `onBeforeInsert` is never used.
- `Parent_Account__c` isn't required.
