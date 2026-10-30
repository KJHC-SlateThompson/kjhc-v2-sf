# kjhc-v2-sf

KJHC's Salesforce platform (V2), built on the KJ_ framework. Each object runs trigger → controller (`KJ_Dispatch_X`) → engine (`KJ_Engine_X`), passing a `KJ_Tool_Package`. Model classes (`KJ_Model_X`) wrap records.

Objects: Account, Contact, `Customer_Property__c`, `Membership__c`, `HVAC_Unit__c`, `Project__c`, `Job__c`. There is no Opportunity; a Project fills that role. The Lead object is being retired, so add nothing that references it.

**Read `docs/architecture.md` before changing framework classes** (anything in `KJ_Tool`, any controller, the trigger pattern, or the model pattern).

## Layout
- `KJ_Tool/`: package, context, result/exception, logging, formatting, test data factory
- `KJ_Model/`: object metadata (`objects/`), `KJ_Model_<Object>`, `KJ_Model_Picklist`
- `KJ_Dispatch/`: `KJ_Dispatch_<Object>Trigger` and `KJ_Dispatch_<Object>`
- `KJ_Engine/`: `KJ_Engine_<Object>` in `classes/<object>/`
- `KJ_Integrate/`, `KJ_UI/`: empty, not built yet
- `KJ_Execute/scripts/apex/`: anonymous Apex scripts

## Conventions
- Class section order: Constants → Member Variables → Static Methods → Instance Methods. Each section opens with a `//*-- Name ---` divider.
- Every class has a header comment: File, Authors, Created, Description, Index.
- Trigger bodies are one line: `KJ_Dispatch_X.receive(KJ_Tool_Package.fromTrigger('X', 'KJ_Dispatch_XTrigger')).applyErrorsToRecords();`
- Controllers only route. Engines hold the logic.
- Engines report problems by adding `KJ_Tool_Exception` to `pkg.result`, never by throwing. Validation failures are `high(VALIDATION_ERROR, message, record)`.
- Engines gather parent Ids, query once per parent object, and read parents with `?.`. Related-record DML is collected in a `Map<Id, SObject>` and run once.
- Model members are the camelCase form of the field API name. No synonyms.
- Models: `setX()` setters. Tool builders: `withX()`. The difference is intentional.
- Picklists are converted only through `KJ_Model_Picklist.mapTo<Type>(String)` / `mapToString(enum)`.
- Defaults are null. Enums default to `UNKNOWN`.
- Fill-if-blank: automations never overwrite a value the user provided.
- Test classes live in `<domain>/main/default/classes/tests/`, named `<Class>_Test`. Build test records with `KJ_Tool_TestDataFactory`.

## Commands
Target org alias: `kjhc-dev-org`. It's a sandbox used for both development and testing.

Only Slate deploys. For checks, use `--dry-run`, queries, or anonymous Apex that rolls back.

```
sf project deploy start --source-dir KJ_Tool KJ_Model KJ_Dispatch KJ_Engine --target-org kjhc-dev-org --dry-run
sf project deploy start --source-dir KJ_Tool KJ_Model KJ_Dispatch KJ_Engine --target-org kjhc-dev-org --test-level RunLocalTests
sf apex run test --test-level RunLocalTests --code-coverage --result-format human --wait 10 --target-org kjhc-dev-org
sf apex run test --class-names KJ_Dispatch_Account_Test --result-format human --wait 10 --target-org kjhc-dev-org
sf apex run --file KJ_Execute/scripts/apex/tests/accountPkgPipelineTest.apex --target-org kjhc-dev-org
```

## Git
- Branch prefixes: `feature/`, `spike/`. Merge to `master` with `--no-ff`.
- Update the matching `docs/` page in the same branch as any code change.

## Docs
- `docs/README.md`: index of the repo's code docs
- `docs/architecture.md`: domains, layers, pipelines, package, errors
- `docs/domains/<object>.md`: classes, automations and tests for each object
- `C:\Users\slate\dev\work\Projects\kjhc-docs`: platform-level and cross-system docs (data model, integrations, decisions, glossary)
- Docs rules: don't invent rationale (`TODO(slate): <question>`), mark anything unconfirmed `UNVERIFIED`, cite file paths, no secret values. `.forceignore` excludes `**/docs/**` and `**/*.md` from deploys.
