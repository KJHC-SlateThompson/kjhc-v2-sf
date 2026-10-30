# Development
Owner: Slate Thompson
Status: stable
Last verified: 2026-10-30
Verified against: kjhc-v2-sf@master ad92d8b

## Environment
- One sandbox is used for both development and testing. Its CLI alias is `kjhc-dev-org`, the project default in `.sf/config.json`.
- No scratch orgs. `config/project-scratch-def.json` is the SFDX default file and isn't used.
- Source API version: 65.0 (`sfdx-project.json`).
- `TODO(slate): How do changes get from kjhc-dev-org to production (change sets, sf deploy, other)?`

## Package directories
Seven package directories, listed in `sfdx-project.json`; `KJ_Model` is the default. `KJ_Integrate`, `KJ_UI` and `KJ_Execute/main/default` hold only `.gitkeep`.

`.forceignore` excludes `**/docs/**`, `**/*.md`, `**/.gitkeep`, `package.xml` and LWC test files from deploys.

## Deploy
Slate runs all deploys. Agents use `--dry-run` only.

```
sf project deploy start --source-dir KJ_Tool KJ_Model KJ_Dispatch KJ_Engine --target-org kjhc-dev-org --dry-run
sf project deploy start --source-dir KJ_Tool KJ_Model KJ_Dispatch KJ_Engine --target-org kjhc-dev-org --test-level RunLocalTests
sf project deploy start --metadata ApexClass:KJ_Engine_Job --target-org kjhc-dev-org
```

Pull a change made in the org:
```
sf project retrieve start --metadata "CustomObject:Job__c" --target-org kjhc-dev-org
sf project retrieve start --metadata "CustomField:Account.Archived__c" --target-org kjhc-dev-org
```

Components already in the repo update in place. New ones land in the default package directory, `KJ_Model`.

## Test
```
sf apex run test --test-level RunLocalTests --code-coverage --result-format human --wait 10 --target-org kjhc-dev-org
sf apex run test --class-names KJ_Dispatch_Job_Test --result-format human --wait 10 --target-org kjhc-dev-org
sf apex run test --tests KJ_Dispatch_Job_Test.insert_Validation_MixedPath --wait 10 --target-org kjhc-dev-org
```

- Every object has a `KJ_Dispatch_<Object>_Test` covering its trigger, controller and engine.
- Models have `KJ_Model_<Object>_Test`.
- Tool classes have tests in `KJ_Tool/main/default/classes/tests/`.
- Build test records with `KJ_Tool_TestDataFactory.createTest<Object>()`.

Anonymous Apex in `KJ_Execute/scripts/apex/` runs against the org. Scripts that write data use a savepoint and roll back, e.g. `tests/accountPkgPipelineTest.apex`.
```
sf apex run --file KJ_Execute/scripts/apex/tests/accountPkgPipelineTest.apex --target-org kjhc-dev-org
```

## Logs
`KJ_Tool_Logger` writes to `System.debug` only.
```
sf apex tail log --color --target-org kjhc-dev-org
sf apex get log --number 1 --target-org kjhc-dev-org
```

## Branching
- **Branches:** `master` is the main branch. Work happens on `feature/<topic>` or `spike/<topic>`.
- **Merging:** merge into `master` with `--no-ff` (history: `Merge branch 'feature/tests'`, etc.).
- **Docs:** update the matching page in `docs/` in the same branch as the code change.

More commands: [cli-cheatsheet.md](cli-cheatsheet.md).
