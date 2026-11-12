# Contact
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

Business-level page: `kjhc-docs:platforms/salesforce/data-model/contact.md`. Framework: [architecture.md](../architecture.md).

## Classes

| Layer | Class | Path |
|---|---|---|
| Trigger | `KJ_Dispatch_ContactTrigger` | `KJ_Dispatch/main/default/triggers/` |
| Controller | `KJ_Dispatch_Contact` | `KJ_Dispatch/main/default/classes/controllers/` |
| Engine | `KJ_Engine_Contact` | `KJ_Engine/main/default/classes/contact/` |
| Model | `KJ_Model_Contact` | `KJ_Model/main/default/classes/` |
| Picklists | `KJ_Model_Picklist` (`Sector`, `ContactMethod`, `RecordOrigin`) | `KJ_Model/main/default/classes/` |
| Metadata | `Contact` (11 custom fields) | `KJ_Model/main/default/objects/Contact/` |

## Entry points
- **Trigger:** `KJ_Dispatch_ContactTrigger`.
- **Called operations:** none.

## Automations
All in `KJ_Engine_Contact`.

| Event | What happens |
|---|---|
| Before insert | **Validation:** at least one of `Phone`, `Email` or `MailingStreet` is required. Otherwise a HIGH `VALIDATION_ERROR` is added on the record. |
| Before insert | `Contact_Method_Preference__c` is set when blank and exactly one of Phone/Email is present: `'Phone'` or `'Email'` |
| Before insert | `Contact_Sector__c` is copied from `Account.Account_Sector__c` when blank and `AccountId` is set |
| Before insert | `Record_Origin__c` = `'KJHC Salesforce V2'` when blank |
| Before insert | `Origin_Created_Date__c` = today when blank |
| After insert | `Origin_Record_Id__c` = the record's Salesforce Id when blank (the Id only exists after insert, so this is one extra update per batch) |
| After insert | `Account.Account_Primary_Contact__c` is set to this Contact when blank on the parent Account. The first Contact in the batch wins. |
| Before update, delete; after update, delete, undelete | None |

## Model
`KJ_Model_Contact` field groups: `VITAL_DATA` (`Id`, `FirstName`, `LastName`, `AccountId`, `Role__c`, `Contact_Sector__c`), `NOTES_DATA`, `COMMERCIAL_DATA` (`Department`), `CONTACT_DATA`, `LOCATION_DATA` (Mailing fields), `METADATA_DATA`.

- `accountName` comes from `Account.Name`. Callers add `PARENT_FIELD_PATHS` (`'Account.Name'`) to their SOQL alongside `getFields()`.
- `toRecord()` leaves out `accountName`.

## Tests

| Test class | Methods |
|---|---|
| `KJ_Dispatch_Contact_Test` | `receive_InvalidPackages_FailPath`, `receive_EmptyTriggerContext_HappyPath`, `insert_FillsBlanks_HappyPath`, `insert_KeepsProvidedValues_HappyPath`, `insert_ContactMethodValidation_MixedPath`, `contactTrigger_BulkBatch_HappyPath` |
| `KJ_Model_Contact_Test` | `build_FromRecordAndDefaults_HappyPath`, `buildAll_AndById_HappyPath`, `toRecord_SkipsUnsetValues_HappyPath`, `setters_RoundTripThroughDatabase_HappyPath` |

## Status
Stable.

## Gaps
- Validation and defaults run on insert only.
- `'Phone'` and `'Email'` are hardcoded in the engine instead of using `KJ_Model_Picklist.mapToString(ContactMethod)`.
- `FieldPulse_Contact_Id__c` isn't marked as an external ID (Account's `FieldPulse_Account_Id__c` is). `TODO(slate): Should it be?`
- `FieldPulse_Contact_Id__c` and `Origin_Account_Id__c` aren't in the model.
