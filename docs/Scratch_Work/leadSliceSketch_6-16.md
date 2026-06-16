# Lead Slice — Day Sketch (6/16/2026)

## 1. State Since the 6/12 Sketch

No commits since the happy-path deploy (`04dd5f2`, 6/11). The fix-first list from 6/12 was started but not finished, and the working tree was left **red**. Git evidence, reconciled against that list:

| 6/12 finding | Working-tree status now |
|---|---|
| #4 wrapped exception had empty message | ✅ Fixed (`?? newNativeException?.getMessage() ?? ''`) |
| #1 LOW resurrects success | ⚠️ Fixed *in intent* — but the `applyLevelFlag` extraction introduced **two compile errors** (see §3) |
| #3 non-trigger guard | 🟡 Vocabulary only — `INVALID_CONTEXT` enum + Formatter case exist; the guard itself is **not** wired |
| #2 `buildPackage()` outside try | ❌ Untouched |
| #5 `didFieldChange()` NPE | ❌ Untouched |
| Failure-lane proof / tests | ❌ Still unproven / still zero |

A full-repo backup (`kjhc.bundle`, 8 refs) was taken 6/15 — consistent with pausing here. So today inherits: **get back to green, then finally prove the failure half of the controller contract.** That proof is the entire reason the spike exists, and it has now been deferred twice.

## 2. Theme

**Green, then prove the contract holds when things break.** 6/11 proved the pipes carry water on the happy path. The spike's actual question — *does the AbstractController template hold under **failure**?* — has never once been exercised. Today: patch the result lane back to compiling, close the construction-side failure hole (#2), and pin the whole failure lane with the repo's first test.

**Ordering rule (held from 6/12):** don't build on a result lane you can't trust. The Result patch goes first; the failure-lane proof is the test, not an afterthought to it.

## 3. Blocks (9:00 – 12:30)

**9:00 – 9:30 — Get to green + baseline commit.**
Fix the two compile errors in `KJ_Tool_Result.cls`:
- `applyLevelFlag(...)` is missing its `void` return type.
- `updateFlags()` passes `e` (a `KJ_Tool_Exception`) where `applyLevelFlag` wants `e.level`.

While in the neighborhood, fix the `level.FATAL` → `Level.FATAL` consistency nit in `KJ_Tool_Exception.fatal(Code, String, Origin)` (compiles today only by accident of case-insensitivity; it's a reader landmine).
**Then actually deploy to the scratch org to confirm green** — the red tree exists *because* edits were made without a compile. Prove it, then commit. Everything after this trusts `result.isSuccess`.

**9:30 – 10:30 — Harden `run()`: catch construction failures too (finding #2).**
`buildPackage()` runs `OrgContext` + `UserContext` SOQL outside the try; if either throws, it escapes raw to the trigger — the exact failure the controller exists to absorb. **Design decision to settle (see §4.2):** moving the call inside the try isn't enough — if it throws, `pkg` is unassigned and the catch/finalize NPE. Initialize `pkg` to an empty `KJ_Tool_Package` before the try (it always has a valid `Result`), then reassign inside. Redeploy, confirm still green. This closes the construction half of the contract.

**10:30 – 10:45 — Break.**

**10:45 – 12:15 — Prove the failure lane with the repo's first test.**
Settle the test-home decision *first* (§4.1) so files don't move twice.
- **`KJ_Dispatch_AbstractController_Test`** *(the centerpiece — the day's thesis)*: a private inner stub controller that throws in `route()`. Assert the wrap → `ROUTING_ERROR` fatal → `result.isSuccess == false` → `finalize()` logs at error. Add a second stub that throws in `buildPackage()` to pin the 9:30 fix. Running the test in the org **is** the live proof — test execution runs in-org and the debug log shows `finalize()` firing.
- **`KJ_Tool_Result_Test`** *(if time — fast, pins #1)*: add FATAL then LOW, assert `isSuccess` stays false. Regression-pins the morning's first fix.

**12:15 – 12:30 — Wrap + commit + EOD note.**
Commit. One honest line at the bottom of this doc: *does the template hold under failure — yes/no?* Queue what carried.

## 4. Decisions to Settle Today

1. **Test home (carried, 6/12 Q4).** Recommendation: `<segment>/main/default/classes/tests/` — zero `sfdx-project.json` change, deploys as-is, conventional. (Folder layout is purely organizational to Salesforce; tests run flat in the org regardless. The "keep tests out of the deployable line" option is a misnomer — Apex tests *must* deploy to run.) **Settle before 10:45.**
2. **How `run()` guarantees a package.** Recommendation: `KJ_Tool_Package pkg = new KJ_Tool_Package();` before the try, reassign from `buildPackage()` inside. If construction throws partway, `pkg` stays the empty-but-valid package and the catch/finalize still work. **Settle during the 9:30 block.**

*Explicitly deferred (not today):* failure *policy* (should a before-trigger fatal `addError()` to block the save?), the Engine.md contract paragraph, and the KJ_Model question. Naming them so they don't masquerade as forgotten.

## 5. What I'm Cutting (and why)

- **Real engine business logic** — the spike's question is about the *template*, not lead rules. The failure lane can be proven with a throwing stub; it doesn't need real behavior. Highest-value cut.
- **Finish #3's guard** — half-built, but not on the critical path for today's thesis. Made the stretch/cut-line item below.
- **#5 `didFieldChange()` guard** — stays dormant because no update logic lands today. Carries with the engine work.
- **Docs catch-up** — carries.

## 6. Cut Line

Banked-on-early-stop order: **green+commit (9:30) → #2 hardened+committed (10:30) → failure proof (12:15).** An early stop still closes two of the review's top-three issues. If the test block finishes early, the **stretch item** is finishing #3's guard (null `triggerContext` → clean `INVALID_CONTEXT`, not an NPE) — the vocabulary's already there.

## 7. Day Checklist

- [ ] Fix the two `KJ_Tool_Result` compile errors; `level.FATAL` → `Level.FATAL`
- [ ] Deploy to scratch org — confirm green
- [ ] Baseline commit
- [ ] `run()` guarantees a package before the try; `buildPackage()` failures now caught (#2)
- [ ] Redeploy — confirm green
- [ ] Decide test home; create the folder
- [ ] `KJ_Dispatch_AbstractController_Test` green: route-throw wrap, buildPackage-throw wrap
- [ ] `KJ_Tool_Result_Test` LOW-after-FATAL *(if time)*
- [ ] Commit + EOD note (template holds under failure: yes/no?)
- [ ] *(stretch)* finish #3 guard

## 8. Definition of Done

The working tree compiles and deploys clean. A failure in `route()` **and** a failure in `buildPackage()` both land as a wrapped `ROUTING_ERROR`, flip `result.isSuccess` false, and log at error — and a green test asserts it. That closes the spike's central question: the template holds under failure, not just success.

---

*(EOD note goes here)*
