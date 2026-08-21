#!/usr/bin/env bash
#
# kjhc-v2-sf — restore domain directory structure
#
# Run from the repo root:   bash fix-structure.sh
# Works in Git Bash on Windows. Review each step before running if you prefer;
# every command below is safe and reversible (nothing is force-pushed, nothing
# is hard-reset, no history is rewritten).
#
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
echo "repo: $(pwd)"
echo "branch: $(git rev-parse --abbrev-ref HEAD)"
echo

# ---------------------------------------------------------------------------
# 1. Put Engine.md back where it belongs.
#
#    It is currently at:
#      KJ_Dispatch/main/default/classes/controllers/docs/Engine.md
#    A docs/ folder holding a .md file inside a Salesforce classes/ directory
#    is not valid metadata, so this would fail `sf project deploy start`.
# ---------------------------------------------------------------------------
MISPLACED="KJ_Dispatch/main/default/classes/controllers/docs/Engine.md"
if [ -f "$MISPLACED" ]; then
  echo "==> moving Engine.md back to KJ_Engine/docs/"
  mkdir -p KJ_Engine/docs
  git mv "$MISPLACED" KJ_Engine/docs/Engine.md
  # remove the now-empty docs dir left inside classes/
  rmdir "KJ_Dispatch/main/default/classes/controllers/docs" 2>/dev/null || true
else
  echo "==> Engine.md already in place, skipping"
fi

# ---------------------------------------------------------------------------
# 2. Stop tracking local git artifacts.
#
#    kjhc.bundle (74 KB local backup bundle) and q (a stray git-log dump)
#    are committed into the repo. --cached leaves both files on your disk.
# ---------------------------------------------------------------------------
echo "==> untracking kjhc.bundle and q (files stay on disk)"
git rm --cached --ignore-unmatch -q kjhc.bundle q

# ---------------------------------------------------------------------------
# 3. Stage the restored scaffolding + updated ignore files.
# ---------------------------------------------------------------------------
echo "==> staging"
git add .forceignore .gitignore
git add \
  KJ_Dispatch/docs/.gitkeep \
  KJ_Engine/docs/.gitkeep \
  KJ_Execute/main/default/.gitkeep \
  KJ_Integrate/main/default/.gitkeep \
  KJ_Model/main/default/.gitkeep \
  KJ_UI/main/default/.gitkeep

echo
echo "==> staged changes:"
git status --short
echo
echo "Review the above, then commit:"
echo
echo "  git commit -m 'Restore domain scaffolding with .gitkeep; move Engine.md to KJ_Engine; untrack local git artifacts'"
echo
