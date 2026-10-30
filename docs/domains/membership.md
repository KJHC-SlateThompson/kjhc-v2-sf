# Membership
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

Business-level page: `kjhc-docs:platforms/salesforce/data-model/membership.md`. Framework: [architecture.md](../architecture.md).

## Classes

| Layer | Class | Path |
|---|---|---|
| Trigger | `KJ_Dispatch_MembershipTrigger` | `KJ_Dispatch/main/default/triggers/` |
| Controller | `KJ_Dispatch_Membership` | `KJ_Dispatch/main/default/classes/controllers/` |
| Engine | `KJ_Engine_Membership` | `KJ_Engine/main/default/classes/membership/` |
| Model | None yet | |
| Metadata | `Membership__c` (5 custom fields; Name is AutoNumber "Membership Number") | `KJ_Model/main/default/objects/Membership__c/` |

## Entry points
- **Trigger:** `KJ_Dispatch_MembershipTrigger`.
- **Called operations:** none.

## Automations
All in `KJ_Engine_Membership`.

| Event | What happens |
|---|---|
| Before insert | `Membership_Start_Date__c` = today when blank |
| Before insert | `Membership_Expiration_Date__c` = start + 1 year when blank |
| Before insert | **Validation:** expiration must be after start. Otherwise a HIGH `VALIDATION_ERROR` is added on the record. |
| All other events | None. `onAfterDelete` holds only a `// disconnect related objects` comment. |

## Relationships
- `Member_Account__c` → Account (SetNull, relationship `Memberships`).
- Child: `HVAC_Unit__c.Membership__c` (SetNull).
- `Membership_Tier__c` uses value set `Kinty_Club_Tier_Picklist_Set`, which isn't in the repo.

## Tests

| Test class | Methods |
|---|---|
| `KJ_Dispatch_Membership_Test` | `receive_InvalidPackages_FailPath`, `receive_EmptyTriggerContext_HappyPath`, `insert_FillsBlanks_HappyPath`, `insert_KeepsProvidedValues_HappyPath`, `insert_DateValidation_MixedPath`, `membershipTrigger_BulkBatch_HappyPath` |

## Status
Stable. No model class.

## Gaps
- Validation runs on insert only.
- `Member_Account__c` isn't required.
- `TODO(slate): What should onAfterDelete "disconnect"?`
