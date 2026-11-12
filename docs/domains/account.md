# Account
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

Business-level page: `kjhc-docs:platforms/salesforce/data-model/account.md`. Framework: [architecture.md](../architecture.md).

## Classes

| Layer | Class | Path |
|---|---|---|
| Trigger | `KJ_Dispatch_AccountTrigger` | `KJ_Dispatch/main/default/triggers/` |
| Controller | `KJ_Dispatch_Account` | `KJ_Dispatch/main/default/classes/controllers/` |
| Engine | `KJ_Engine_Account` | `KJ_Engine/main/default/classes/account/` |
| Model | `KJ_Model_Account` | `KJ_Model/main/default/classes/` |
| Picklists | `KJ_Model_Picklist` (`AccountStatus`, `Sector`, `Territory`, `RecordOrigin`) | `KJ_Model/main/default/classes/` |
| Metadata | `Account` (27 custom fields) | `KJ_Model/main/default/objects/Account/` |

## Entry points
- **Trigger:** every DML on Account goes through `KJ_Dispatch_AccountTrigger`.
- **Called operation:** `KJ_Dispatch_Account.archive(pkg)`. The data bundle entries hold `KJ_Model_Account` values. The engine sets `Archived__c = true` on each and updates them. With no entries, it adds a HIGH `MISSING_DATA` exception.

## Automations
All in `KJ_Engine_Account`.

| Event | What happens |
|---|---|
| Before insert | `Customer_Since__c` = today when `Account_Status__c` maps to `CURRENT_CUSTOMER` and `Customer_Since__c` is blank |
| Before insert | `Record_Origin__c` = `'KJHC Salesforce V2'` when blank |
| Before insert | `Origin_Created_Date__c` = today when blank |
| After insert | `Origin_Record_Id__c` = the record's Salesforce Id when blank (the Id only exists after insert, so this is one extra update per batch). The FP → SF sync provides all three origin fields (`FieldPulse`, the FP id, the FP created date), so it never triggers this. |
| Before insert | Billing street, city, state code, postal code and country code are copied from `Service_Address__c` when `BillingStreet` is blank and the service street isn't |
| Before insert | `Branch_Territory__c` is set from `Service_Address__StateCode__s` when blank: `AR` → `NWA`, `OK` → `Tulsa`. Other states stay blank. |
| Before update | `Customer_Since__c` = today when the status changed, it maps to `CURRENT_CUSTOMER`, and `Customer_Since__c` is blank |
| Before delete | Notes Accounts that have any Contact, Job (`Jobs__r`), Membership (`Memberships__r`) or Project (`Projects__r`). Customer Properties already block the delete through the Restrict lookup `Customer_Property__c.Property_Owner_Account__c`. |
| After delete | Blocks the delete (`addError`) of the Accounts noted in before delete, unless `MasterRecordId` is set. A merge loser's children move to the master, so merges go through. Salesforce only sets `MasterRecordId` in after delete, which is why the check is split. |
| After update, undelete | None |

Other engines that write to Account:
- `KJ_Engine_Contact`, after insert: sets `Account_Primary_Contact__c` on Accounts where it's blank. The first Contact in the batch wins.
- `KJ_Engine_Job`, after insert and update: sets `Last_Service_Date__c` to the date of `Actual_End__c` for Jobs with `Job_Status__c = 'Completed'`, when later than the current value.

## Model
`KJ_Model_Account` field groups:

| Group | Fields |
|---|---|
| `VITAL_DATA` | `Id`, `Name`, `ParentId`, `Account_Status__c`, `Account_Sector__c`, `Branch_Territory__c` |
| `NOTES_DATA` | `Office_Notes__c`, `Field_Notes__c` |
| `CONTACT_DATA` | `Phone`, `Account_Primary_Contact__c` |
| `LOCATION_DATA` | `BillingStreet`, `BillingCity`, `BillingState`, `BillingPostalCode` |
| `FINANCIAL_DATA` | `Invoiced_Revenue__c`, `Customer_Since__c`, `Last_Service_Date__c` |
| `REFERRAL_DATA` | `Account_Lead_Source__c`, `Referred_By__c`, `Referred_By_Email__c`, `Referred_By_Phone__c` |
| `ATTRIBUTION_DATA` | `GCLID__c`, `UTM_Source__c`, `UTM_Medium__c`, `UTM_Campaign__c`, `UTM_Term__c`, `UTM_Content__c` |
| `METADATA_DATA` | `Archived__c`, `OwnerId`, `CreatedById`, `LastModifiedById`, `Record_Origin__c`, `Origin_Record_Id__c`, `Origin_Created_Date__c`, `FieldPulse_Account_Id__c`, `QBO_Account_Id__c` |

`toRecord()` leaves out `CreatedById` and `LastModifiedById`, which aren't writeable.

Not in the model: `Service_Address__c`, `BillingCountry`, `Originating_Lead__c`.

## Tests

| Test class | Methods |
|---|---|
| `KJ_Dispatch_Account_Test` (`KJ_Dispatch/main/default/classes/tests/`) | `receive_InvalidPackages_FailPath`, `receive_EmptyTriggerContext_HappyPath`, `insert_FillsBlanks_HappyPath`, `insert_KeepsProvidedValues_HappyPath`, `update_CustomerSince_HappyPath`, `delete_RelatedRecordGuard_MixedPath`, `merge_LoserWithRelatedRecords_HappyPath`, `archive_HappyAndFailPaths`, `accountTrigger_BulkBatch_HappyPath` |
| `KJ_Model_Account_Test` (`KJ_Model/main/default/classes/tests/`) | `build_FromRecordAndDefaults_HappyPath`, `buildAll_AndById_HappyPath`, `toRecord_SkipsUnsetValues_HappyPath`, `setters_RoundTripThroughDatabase_HappyPath` |

Test data: `KJ_Tool_TestDataFactory.createTestAccount(...)`.

## Status
Stable. Trigger pipeline, automations, model and `archive` are built and tested.

## Gaps
- `Record_Origin__c` is a Text field. The engine writes `'KJHC Salesforce V2'`, which `KJ_Model_Picklist.mapToRecordOrigin` maps to `UNKNOWN`.
- `Originating_Lead__c` still looks up Lead (see `kjhc-docs:decisions/0002-retire-lead-object.md`).
- The `instanceof KJ_Model_Account` check in `KJ_Engine_Account.archive` has an empty body. An entry that isn't a model throws on the cast and surfaces as FATAL `OPERATION_ERROR`.
- `onAfterDelete` calls `addError` directly instead of adding to `pkg.result`.
- Prod deploys so far (2026-11-12) were Apex only (`classes` and `triggers` in `KJ_Tool`, `KJ_Model`, `KJ_Dispatch`, `KJ_Engine`). The object metadata in `KJ_Model/objects` came from the sandbox and was not deployed to prod.
- `Referred_By_Phone__c` is a Number field, so `referredByPhone` is a Decimal.
- Billing copy and territory default run on insert only.
- `TODO(slate): Should Branch_Territory__c default for states other than AR and OK?`
