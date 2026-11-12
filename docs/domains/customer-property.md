# Customer Property
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

Business-level page: `kjhc-docs:platforms/salesforce/data-model/customer-property.md`. Framework: [architecture.md](../architecture.md).

## Classes

| Layer | Class | Path |
|---|---|---|
| Trigger | `KJ_Dispatch_CustomerPropertyTrigger` | `KJ_Dispatch/main/default/triggers/` |
| Controller | `KJ_Dispatch_CustomerProperty` | `KJ_Dispatch/main/default/classes/controllers/` |
| Engine | `KJ_Engine_CustomerProperty` | `KJ_Engine/main/default/classes/customer_property/` |
| Model | None yet | |
| Metadata | `Customer_Property__c` (10 custom fields; Name is Text) | `KJ_Model/main/default/objects/Customer_Property__c/` |

## Entry points
- **Trigger:** `KJ_Dispatch_CustomerPropertyTrigger`.
- **Called operations:** none.

## Automations
All in `KJ_Engine_CustomerProperty`.

| Event | What happens |
|---|---|
| Before insert | `Property_Sector__c` is copied from `Property_Owner_Account__r.Account_Sector__c` when blank |
| Before insert | `Property_Address__c` components (street, city, state code, postal code, country code) are copied from the owner Account's `Service_Address__c` when the property street is blank and the Account's isn't |
| Before insert | `Name` = `Property_Address__Street__s` when blank |
| Before insert | `Record_Origin__c` = `'KJHC Salesforce V2'` when blank |
| Before insert | `Origin_Created_Date__c` = today when blank |
| After insert | `Origin_Record_Id__c` = the record's Salesforce Id when blank (the Id only exists after insert, so this is one extra update per batch) |
| All other events | None except the after insert above. `onAfterDelete` holds only a `// disconnect related objects` comment. |

## Relationships
- `Property_Owner_Account__c` → Account: required, delete Restrict (relationship `Customer_Properties`).
- Children:
  - `HVAC_Unit__c.Customer_Property__c` (SetNull)
  - `Project__c.Customer_Property__c` (SetNull)
  - `Job__c.Customer_Property__c` (Restrict)

## Tests

| Test class | Methods |
|---|---|
| `KJ_Dispatch_CustomerProperty_Test` | `receive_InvalidPackages_FailPath`, `receive_EmptyTriggerContext_HappyPath`, `insert_FillsBlanks_HappyPath`, `insert_KeepsProvidedValues_HappyPath`, `customerPropertyTrigger_BulkBatch_HappyPath` |

## Status
Stable. No model class.

## Gaps
- `TODO(slate): What should onAfterDelete "disconnect"? The lookups on HVAC Unit and Project are already SetNull.`
- When both the property street and the Account service street are blank, `Name` stays blank.
