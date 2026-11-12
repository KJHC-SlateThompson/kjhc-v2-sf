# HVAC Unit
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

Business-level page: `kjhc-docs:platforms/salesforce/data-model/hvac-unit.md`. Framework: [architecture.md](../architecture.md).

## Classes

| Layer | Class | Path |
|---|---|---|
| Trigger | `KJ_Dispatch_HvacUnitTrigger` | `KJ_Dispatch/main/default/triggers/` |
| Controller | `KJ_Dispatch_HvacUnit` | `KJ_Dispatch/main/default/classes/controllers/` |
| Engine | `KJ_Engine_HvacUnit` | `KJ_Engine/main/default/classes/hvac_unit/` |
| Model | None yet | |
| Metadata | `HVAC_Unit__c` (23 custom fields; Name is AutoNumber "Unit Number") | `KJ_Model/main/default/objects/HVAC_Unit__c/` |

## Entry points
- **Trigger:** `KJ_Dispatch_HvacUnitTrigger`.
- **Called operations:** none.

## Automations
All in `KJ_Engine_HvacUnit`.

| Event | What happens |
|---|---|
| Before insert | **Validation:** when `Membership__c` is set, `Membership__r.Member_Account__c` must equal `Customer_Property__r.Property_Owner_Account__c`. Otherwise a HIGH `VALIDATION_ERROR` is added on the record. |
| Before insert | `Record_Origin__c` = `'KJHC Salesforce V2'` when blank |
| Before insert | `Origin_Created_Date__c` = today when blank |
| After insert | `Origin_Record_ID__c` = the record's Salesforce Id when blank (the Id only exists after insert, so this is one extra update per batch) |
| All other events | None |

## Relationships
- `Customer_Property__c` → Customer Property (SetNull).
- `Membership__c` → Membership (SetNull).
- Picklists use value sets `Unit_Type_Picklist_Set`, `Unit_Brands_Picklist_Set` and `Unit_Fuel_Type_Picklist_Set`, which aren't in the repo.

## Tests

| Test class | Methods |
|---|---|
| `KJ_Dispatch_HvacUnit_Test` | `receive_InvalidPackages_FailPath`, `receive_EmptyTriggerContext_HappyPath`, `insert_MembershipAccountValidation_MixedPath`, `insert_OriginFields_HappyPath`, `hvacUnitTrigger_BulkBatch_HappyPath` |

## Status
Stable. No model class.

## Gaps
- Validation runs on insert only. Changing `Membership__c` or `Customer_Property__c` later isn't checked.
- A unit with a Membership but no Customer Property fails validation, unless the Membership also has no Account.
- The field is `Origin_Record_ID__c` here, but `Origin_Record_Id__c` on Account, Contact and Customer Property.
