# Conventions
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

## Naming
- **Classes:** `KJ_<Domain>_<Name>`, where Domain is one of Tool, Model, Dispatch, Engine, Integrate, UI or Execute. Object classes use the object's name with no underscores and no `__c`: `KJ_Engine_CustomerProperty`, `KJ_Dispatch_HvacUnit`.
- **Triggers:** `KJ_Dispatch_<Object>Trigger`.
- **Test classes:** `<Class>_Test` in `<Domain>/main/default/classes/tests/`. Test methods are named `<method>_<Scenario>_<HappyPath|FailPath|MixedPath>`:
  ```apex
  static void insert_ContactMethodValidation_MixedPath(){   // KJ_Dispatch_Contact_Test
  ```
- **Engine folders:** `KJ_Engine/main/default/classes/<object_snake_case>/` (`customer_property/`, `hvac_unit/`).
- **Model members:** the camelCase form of the field API name, with no synonyms: `Customer_Since__c` → `customerSince`, `Account_Primary_Contact__c` → `primaryContactId`. For Id lookups the member ends in `Id`.

## Class header
```apex
/*
*   File: KJ_Dispatch_Account.cls
*   Authors: Slate Thompson (Slate@kintyjones.com)
*   Created: 7/22/2026
*   Description: This class is built to control operations related to the Account object
*
*   Index:
*       Constants                   private
*       Static Methods              public + private    (private: route)
*/
```
The Index lists each section with its visibility.

## Section order
Constants → Member Variables → Static Methods → Instance Methods. Leave out sections the class doesn't have. Each section opens with a divider, and subsections are indented:
```apex
//*-- Constants -------------------------------------------------------------------------------
//*--    Field Groupings ----------------------------------------------------------------------
```
Enums live under Constants (`KJ_Tool_Exception.Code`, `KJ_Tool_Exception.Level`).

## Members
Public read, private write:
```apex
public KJ_Tool_Result result { get; private set; }
```

## Factories and defaults
- The constructor sets every member to its default.
- `build(...)` overlays non-null inputs with `??`.
- The no-arg `build()` calls the full overload with `null`.

```apex
newModel.customerSince = (Date) read(source, Account.Customer_Since__c) ?? newModel.customerSince;
```

Defaults: scalars are null, Booleans are `false`, picklist enums are `UNKNOWN`.

## setX vs withX
- **Models** use `setX()`, which returns `this` (`KJ_Model_Account.setArchived(true)`).
- **Tool builders** use `withX()` for assembly (`KJ_Tool_Package.build().withLabel(...).withTriggerContext(...)`), and `setX()` for plain mutators (`KJ_Tool_Result.setMessage`).

The two exist for different use cases (stated by Slate). Both ignore null: `this.x = initX ?? this.x;`.

## Picklists
Every picklist value goes through `KJ_Model_Picklist`. Each picklist gets an enum, a `mapTo<Type>(String)` and a `mapToString(<enum>)`:
```apex
KJ_Model_Picklist.AccountStatus status = KJ_Model_Picklist.mapToAccountStatus(record.Account_Status__c);
if(status == KJ_Model_Picklist.AccountStatus.CURRENT_CUSTOMER){ ... }
```
`mapTo<Type>` is case-insensitive and returns `UNKNOWN` for blank or unmapped values. `mapToString(UNKNOWN)` returns null.

## Triggers and controllers
- A trigger body is one line, and it covers all 7 events:
  ```apex
  KJ_Dispatch_Job.receive(KJ_Tool_Package.fromTrigger('Job', 'KJ_Dispatch_JobTrigger')).applyErrorsToRecords();
  ```
- Controllers start with `if(pkg !== (pkg = KJ_Tool_Package.nullCheck(pkg))) { return pkg; }`, wrap their work in `try/catch`, and turn the exception into a FATAL `KJ_Tool_Exception`.

## Engines
- Methods are `public static void on<Before|After><Event>(KJ_Tool_Package pkg)`, one per trigger event. Empty methods stay in the class.
- Validation adds an exception and moves on. It never throws:
  ```apex
  pkg.result.addException(KJ_Tool_Exception.high(KJ_Tool_Exception.Code.VALIDATION_ERROR, 'No Parent Account. Parent Account required.', record));
  continue;
  ```
- Fill-if-blank: a default is only written when the field is null or blank.
- Parent reads use `?.`, e.g. `parentAccount?.Account_Sector__c`.
- See [architecture.md](architecture.md) for the query and DML shape.
