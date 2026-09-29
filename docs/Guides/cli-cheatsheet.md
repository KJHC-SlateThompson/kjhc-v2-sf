# CLI Cheat Sheet

Placeholders are in `<angle-brackets>`. Commands marked **⚠** discard work or change an org and can't be easily undone.

- [Git](#git)
  - [Setup & Config](#setup--config) · [Viewing](#viewing) · [Staging](#staging) · [Committing](#committing) · [Branching & Merging](#branching--merging) · [Rebasing](#rebasing) · [Remotes](#remotes) · [Stashing](#stashing) · [Undoing](#undoing)
- [Salesforce CLI (sf)](#salesforce-cli-sf)
  - [Org Handling](#org-handling) · [Scratch Orgs](#scratch-orgs) · [Project & Generation](#project--generation) · [Metadata Retrieval](#metadata-retrieval) · [Deployment](#deployment) · [Org Data Retrieval](#org-data-retrieval) · [Org Data Modification](#org-data-modification) · [Apex & Testing](#apex--testing) · [Logs](#logs) · [CLI Help & Maintenance](#cli-help--maintenance)

---

## Git

### Setup & Config

| Command | Does |
|---|---|
| `git init` | Start a repo in the current folder |
| `git clone <url>` | Copy a remote repo locally |
| `git config --global user.name "<name>"` | Set commit author name |
| `git config --global user.email "<email>"` | Set commit author email |
| `git config --list --show-origin` | Show all config and which file it came from |
| `git config --global init.defaultBranch main` | Default new repos to `main` |

### Viewing

| Command | Does |
|---|---|
| `git status` | Show staged, unstaged, and untracked files |
| `git status -sb` | Short status with branch info |
| `git log --oneline --graph --all` | Compact history of all branches as a graph |
| `git log -n 5` | Last 5 commits |
| `git log -p <file>` | History of a file with diffs |
| `git log --author="<name>"` | Commits by one author |
| `git diff` | Unstaged changes |
| `git diff --staged` | Staged changes (what will be committed) |
| `git diff <branch-a>..<branch-b>` | Differences between two branches |
| `git show <commit>` | One commit's message and diff |
| `git blame <file>` | Who last changed each line |
| `git branch -vv` | Local branches with their upstream and last commit |

### Staging

| Command | Does |
|---|---|
| `git add <file>` | Stage a file |
| `git add .` | Stage everything in the current folder down |
| `git add -p` | Stage changes hunk by hunk |
| `git restore --staged <file>` | Unstage a file (keeps the changes) |
| `git rm <file>` | Delete a file and stage the deletion |
| `git rm --cached <file>` | Stop tracking a file but keep it on disk |
| `git mv <old> <new>` | Rename/move and stage it |

### Committing

| Command | Does |
|---|---|
| `git commit -m "<message>"` | Commit staged changes |
| `git commit -am "<message>"` | Stage tracked files and commit in one step |
| `git commit --amend` | Edit the last commit's message/contents (don't use on pushed commits) |
| `git commit --amend --no-edit` | Add staged changes to the last commit, same message |

### Branching & Merging

| Command | Does |
|---|---|
| `git branch` | List local branches |
| `git branch -a` | List local and remote branches |
| `git switch <branch>` | Move to a branch |
| `git switch -c <branch>` | Create a branch and move to it |
| `git branch -m <new-name>` | Rename the current branch |
| `git branch -d <branch>` | Delete a merged branch |
| `git branch -D <branch>` | **⚠** Force-delete a branch, merged or not |
| `git merge <branch>` | Merge a branch into the current one |
| `git merge --no-ff <branch>` | Merge and always create a merge commit |
| `git merge --abort` | Back out of a conflicted merge |
| `git cherry-pick <commit>` | Apply one commit onto the current branch |

### Rebasing

| Command | Does |
|---|---|
| `git rebase <branch>` | Replay current branch's commits on top of `<branch>` |
| `git rebase -i HEAD~<n>` | Reorder, squash, or edit the last `<n>` commits |
| `git rebase --continue` | Continue after resolving a conflict |
| `git rebase --abort` | Cancel the rebase and return to where you started |

### Remotes

| Command | Does |
|---|---|
| `git remote -v` | List remotes and their URLs |
| `git remote add origin <url>` | Add a remote |
| `git fetch` | Download remote changes without merging |
| `git fetch --prune` | Fetch and drop references to deleted remote branches |
| `git pull` | Fetch and merge the upstream branch |
| `git pull --rebase` | Fetch and rebase onto the upstream branch |
| `git push` | Push current branch to its upstream |
| `git push -u origin <branch>` | Push a new branch and set its upstream |
| `git push origin --delete <branch>` | Delete a remote branch |
| `git push --force-with-lease` | **⚠** Overwrite remote branch, but only if nobody else pushed |

### Stashing

| Command | Does |
|---|---|
| `git stash` | Shelve uncommitted changes |
| `git stash -u` | Shelve including untracked files |
| `git stash push -m "<note>"` | Shelve with a label |
| `git stash list` | List stashes |
| `git stash pop` | Reapply the latest stash and remove it |
| `git stash apply stash@{<n>}` | Reapply a specific stash and keep it |
| `git stash drop stash@{<n>}` | Delete a specific stash |

### Undoing

| Command | Does |
|---|---|
| `git restore <file>` | **⚠** Discard unstaged changes to a file |
| `git restore --source=<commit> <file>` | Restore a file as it was at a commit |
| `git revert <commit>` | New commit that undoes `<commit>` (safe for pushed history) |
| `git reset --soft HEAD~1` | Undo last commit, keep changes staged |
| `git reset HEAD~1` | Undo last commit, keep changes unstaged |
| `git reset --hard HEAD~1` | **⚠** Undo last commit and discard its changes |
| `git reset --hard origin/<branch>` | **⚠** Make local branch match the remote exactly |
| `git clean -nd` | Preview untracked files/folders that would be deleted |
| `git clean -fd` | **⚠** Delete untracked files and folders |
| `git reflog` | Every position HEAD has been at; use to recover "lost" commits |

---

## Salesforce CLI (sf)

Most commands take `--target-org <alias>` (`-o`). Without it, they use the default set by `sf config set target-org`. Add `--json` to any command for machine-readable output.

### Org Handling

| Command | Does |
|---|---|
| `sf org login web --alias <alias>` | Log in to a production/dev org in the browser |
| `sf org login web --alias <alias> --instance-url https://test.salesforce.com` | Log in to a sandbox |
| `sf org login web --alias <alias> --set-default-dev-hub` | Log in and set as Dev Hub |
| `sf org list` | List all authorized orgs |
| `sf org list --clean` | Remove expired/deleted scratch orgs from the list |
| `sf org display --target-org <alias>` | Org ID, username, instance URL, API version |
| `sf org display --target-org <alias> --verbose` | Same, plus the SFDX auth URL |
| `sf org open --target-org <alias>` | Open the org in the browser |
| `sf org open --target-org <alias> --path lightning/setup/SetupOneHome/home` | Open straight to a page (Setup here) |
| `sf config set target-org=<alias>` | Set default org for this project |
| `sf config set target-org=<alias> --global` | Set default org everywhere |
| `sf config get target-org` | Show the current default org |
| `sf config list` | Show all config values |
| `sf alias set <alias>=<username>` | Create/change an alias |
| `sf alias list` | List aliases |
| `sf org logout --target-org <alias>` | Log out of one org |

### Scratch Orgs

| Command | Does |
|---|---|
| `sf org create scratch --definition-file config/project-scratch-def.json --alias <alias> --duration-days 7 --set-default` | Create a scratch org |
| `sf org delete scratch --target-org <alias>` | **⚠** Delete a scratch org |
| `sf org generate password --target-org <alias>` | Generate a password for the scratch org user |

### Project & Generation

| Command | Does |
|---|---|
| `sf project generate --name <name>` | New SFDX project |
| `sf project generate manifest --source-dir force-app --output-dir manifest` | `package.xml` from local source |
| `sf project generate manifest --from-org <alias> --output-dir manifest` | `package.xml` of everything in an org |
| `sf apex generate class --name <Name> --output-dir force-app/main/default/classes` | New Apex class |
| `sf apex generate trigger --name <Name> --sobject <Object> --output-dir force-app/main/default/triggers` | New Apex trigger |
| `sf lightning generate component --type lwc --name <name> --output-dir force-app/main/default/lwc` | New LWC |

### Metadata Retrieval

| Command | Does |
|---|---|
| `sf project retrieve start --source-dir force-app` | Pull everything under `force-app` from the org |
| `sf project retrieve start --metadata ApexClass:<Name>` | Pull one class |
| `sf project retrieve start --metadata "CustomObject:<Object__c>"` | Pull one object |
| `sf project retrieve start --metadata ApexClass` | Pull all Apex classes |
| `sf project retrieve start --manifest manifest/package.xml` | Pull what's listed in a manifest |
| `sf project retrieve start` | Pull remote changes (source-tracked orgs only) |
| `sf project retrieve preview` | Show what a tracked retrieve would pull |
| `sf org list metadata-types` | List all metadata types the org supports |
| `sf org list metadata --metadata-type <Type>` | List every component of a type in the org |

### Deployment

| Command | Does |
|---|---|
| `sf project deploy start --source-dir force-app` | **⚠** Deploy everything under `force-app` |
| `sf project deploy start --metadata ApexClass:<Name>` | **⚠** Deploy one class |
| `sf project deploy start --manifest manifest/package.xml` | **⚠** Deploy what's in a manifest |
| `sf project deploy start --source-dir force-app --dry-run` | Validate without saving anything |
| `sf project deploy start --source-dir force-app --test-level RunLocalTests` | **⚠** Deploy and run all local tests |
| `sf project deploy start --source-dir force-app --test-level RunSpecifiedTests --tests <TestClass>` | **⚠** Deploy and run only named tests |
| `sf project deploy start --manifest manifest/package.xml --post-destructive-changes manifest/destructiveChanges.xml` | **⚠** Deploy, then delete components listed in `destructiveChanges.xml` |
| `sf project deploy preview` | Show what a tracked deploy would push |
| `sf project deploy validate --source-dir force-app --test-level RunLocalTests` | Validate for a later quick deploy (returns a job ID) |
| `sf project deploy quick --job-id <id>` | **⚠** Deploy a validated job without re-running tests |
| `sf project deploy report --job-id <id>` | Status of a deploy |
| `sf project deploy resume --job-id <id>` | Reattach to a deploy that timed out in the terminal |
| `sf project deploy cancel --job-id <id>` | Cancel a running deploy |
| `sf project reset tracking` | Reset source tracking to match the org |

### Org Data Retrieval

| Command | Does |
|---|---|
| `sf data query --query "SELECT Id, Name FROM Account LIMIT 10"` | Run SOQL |
| `sf data query --query "<soql>" --result-format csv > <file>.csv` | SOQL results to CSV |
| `sf data query --file <query>.soql` | Run SOQL from a file |
| `sf data query --query "SELECT Id, Name FROM ApexClass" --use-tooling-api` | Query Tooling API objects |
| `sf data get record --sobject <Object> --record-id <id>` | One record by ID |
| `sf data search --query "FIND {<text>} IN ALL FIELDS RETURNING Account(Name)"` | Run SOSL |
| `sf data export bulk --query "<soql>" --output-file <file>.csv --result-format csv --wait 10` | Large export via Bulk API 2.0 |
| `sf data export tree --query "<soql>" --plan --output-dir data` | Export records (with relationships) to JSON |
| `sf sobject describe --sobject <Object>` | Fields, types, and relationships for an object |
| `sf sobject list --sobject custom` | List custom objects (`all` / `standard` also work) |

### Org Data Modification

| Command | Does |
|---|---|
| `sf data create record --sobject Account --values "Name='<name>'"` | **⚠** Create one record |
| `sf data update record --sobject <Object> --record-id <id> --values "<Field>='<value>'"` | **⚠** Update one record |
| `sf data delete record --sobject <Object> --record-id <id>` | **⚠** Delete one record |
| `sf data import tree --plan data/<plan>.json` | **⚠** Import records from a tree export |
| `sf data upsert bulk --sobject <Object> --file <file>.csv --external-id <Field> --wait 10` | **⚠** Bulk upsert from CSV |
| `sf data delete bulk --sobject <Object> --file <ids>.csv --wait 10` | **⚠** Bulk delete by ID from CSV |

### Apex & Testing

| Command | Does |
|---|---|
| `sf apex run --file scripts/apex/<script>.apex` | Run anonymous Apex from a file |
| `sf apex run` | Type anonymous Apex interactively (Ctrl+D to run) |
| `sf apex run test --class-names <TestClass> --result-format human --wait 10` | Run one test class |
| `sf apex run test --tests <TestClass>.<method> --wait 10` | Run one test method |
| `sf apex run test --test-level RunLocalTests --code-coverage --result-format human --wait 20` | Run all local tests with coverage |
| `sf apex get test --test-run-id <id>` | Results of an earlier test run |

### Logs

| Command | Does |
|---|---|
| `sf apex tail log --color` | Stream debug logs live |
| `sf apex list log` | List debug logs in the org |
| `sf apex get log --number 1` | Fetch the most recent log |
| `sf apex get log --log-id <id>` | Fetch a specific log |

### CLI Help & Maintenance

| Command | Does |
|---|---|
| `sf --version` | CLI and plugin versions |
| `sf update` | Update the CLI |
| `sf commands` | List every command |
| `sf search` | Interactive command search |
| `sf <command> --help` | Flags and examples for a command |
| `sf plugins` | List installed plugins |
| `sf doctor` | Diagnose CLI problems |
