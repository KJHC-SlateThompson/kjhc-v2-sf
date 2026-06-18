# Lead Slice — Day Sketch (6/17/2026)

## 1. State Since the 6/16 Sketch

The handoff summary (and the 6/16 plan) are **behind the working tree**. Reconciled against `git log` + the actual files, not the summary:

| 6/16 block | Real status now |
|---|---|
| 9:00 — `KJ_Tool_Result` compile errors + `Level.FATAL` nit | ✅ **Done & committed** (`c83457a`, `1edcbcf`). `applyLevelFlag(Level)` returns void, takes `e.level`; LOW-after-FATAL correct; `fatal()` uses `Level.FATAL` throughout. |
| 9:30 — #2 harden `run()` (guarantee a package) | ✅ **Done — but UNCOMMITTED.** `run()` opens `KJ_Tool_Package pkg = KJ_Tool_Package.build();`; the no-arg `build()` overload exists. A `buildPackage()` throw no longer NPEs the catch/finalize. |
| 10:45 — failure-lane test (the centerpiece) | ❌ **Not started.** Zero `@isTest` classes. The spike's thesis is still unproven — deferred 6/12 → 6/16 → today. |

The "CRITICAL OPEN BUG" the handoff describes as unfixed is **fixed** — its only risk is that it's *uncommitted*.

**Scope decided today (6/17):** beyond banking the fix and writing the proof, two production changes are in:
- **`run()` returns `KJ_Tool_Package`** (was `void`).
- **Fix the mislabeled error** — by guarding the precondition in `route()`, *not* by reworking the catch (see §4.2).

## 2. Theme

**Stop deferring the proof — and make the failure lane say what actually went wrong.** The fixes from the last two days are done; the spike's question (*does the template hold under failure?*) is one test away from answered. Today: bank the in-flight fix, make `run()` return its package, fix `route()` so a missing trigger context is labeled honestly (`INVALID_CONTEXT`) instead of NPE-ing into a generic wrap, then prove the whole lane with the repo's first test.

**Ordering rule:** don't build tests on an uncommitted/uncompiled base. Bank the done fix (green) first; make the contract changes (green) second; prove it third.

## 3. Blocks (~9:00 – 12:30, start time illustrative)

**Block A1 — Bank the in-flight #2 fix (~20 min).**
Deploy the current working tree to `KJHC_V2_Dev_Org`, confirm it **compiles & deploys green** (the 6/12 red-tree lesson applies even though it reads clean), then commit: *"#2: run() guarantees a package; buildPackage() failures now caught."* Banks verified work before layering new edits.

**Block A2 — Controller contract changes (~40 min).** Then deploy → green → commit.
1. **`run()` returns `KJ_Tool_Package`.** Add `return pkg;`; change the signature. The trigger is the only caller (verified) and ignores the return, so it's backward-compatible — but the return is what Block B asserts on, and what a future before-trigger `addError()` policy will read.
2. **Catch stays as-is — single catch-all, wrap, append.** No change. It is the net for *unexpected* failures; one generic wrap is correct (see §4.2 for the principle).
3. **Mislabel fix — guard the precondition in `LeadController.route()`.** A missing trigger context is a *checkable condition*, not a runtime surprise, so detect it and record it — no throw, no helper:
   ```apex
   protected override void route(KJ_Tool_Package pkg){
       if (pkg.triggerContext == null){
           pkg.result.addException(KJ_Tool_Exception.fatal(
               KJ_Tool_Exception.Code.INVALID_CONTEXT,
               'Lead controller invoked without a trigger context.'));
           return;
       }
       KJ_Tool_TriggerContext ctx = pkg.triggerContext;
       if (ctx.isBefore){
           if (ctx.isInsert) { KJ_Engine_LeadEngine.onBeforeInsert(pkg); }
           if (ctx.isUpdate) { KJ_Engine_LeadEngine.onBeforeUpdate(pkg); }
       }
       else if (ctx.isAfter){ /* after methods as needed */ }
   }
   ```
   Kills the NPE, produces the correct `INVALID_CONTEXT` label, leaves the catch untouched.

**Block B — The failure-lane test. The centerpiece (~90 min).**
`KJ_Dispatch_AbstractController_Test` → `KJ_Dispatch/main/default/classes/tests/` (see §4.1). Because `run()` now **returns** the package, tests assert on the returned `pkg.result` directly — no `finalize()`-capture seam (the return value made the class trivially testable). Private inner stub controllers implement `controllerName()`/`route()`; route/happy stubs also override `buildPackage()` to return a minimal `KJ_Tool_Package.build()` so the test isn't coupled to `OrgContext`/`UserContext` SOQL.

1. **route throws** — stub `route()` throws a test-local `extends Exception`. Assert `isSuccess == false`, 1 exception, `code == ROUTING_ERROR`, `level == FATAL`.
2. **buildPackage throws** — stub `buildPackage()` throws native. Assert `run()` returns a **non-null** pkg with `code == ROUTING_ERROR` (pre-#2 this NPE'd inside the catch and escaped). Regression for the construction hole.
3. **happy path** — stub `route()` no-ops. Assert `isSuccess == true`, zero exceptions.
4. **invalid context (real controller)** — `new KJ_Dispatch_LeadController().run()` invoked outside a trigger → `triggerContext` is null. Assert `code == INVALID_CONTEXT` (not `ROUTING_ERROR`), `isSuccess == false`. Proves the A2 #3 guard end-to-end against the real controller.

Running these in-org is the live proof — the debug log shows `finalize()` firing at error for the failure cases.

**Block C — Result LOW-after-FATAL regression test (~30 min, if time).**
`KJ_Tool_Result_Test` → `KJ_Tool/main/default/classes/tests/`. `addException(FATAL)` then `addException(LOW)`; assert `isSuccess` stays `false`, `hasFatals && hasLows` true. Pins the fix already committed in `c83457a`.

**Block D — Housekeeping: untrack the bundle (~15 min).**
`git rm --cached kjhc.bundle`, add `*.bundle` to `.gitignore`, isolated commit. Confirmed tracked (74KB binary) and uncovered by `.gitignore`.

**Wrap (~15 min).** Commit. EOD note answering: *does the template hold under failure — yes/no?* Queue what carried.

## 4. Decisions to Settle Today

1. **Test home (carried).** Per-segment `<segment>/main/default/classes/tests/`. `KJ_Dispatch_AbstractController_Test` → `KJ_Dispatch`; `KJ_Tool_Result_Test` → `KJ_Tool`. Zero `sfdx-project.json` change; organizational only. **Settle before Block B.**

2. **`run()` returns `KJ_Tool_Package` — DECIDED. Mislabel fix = guard in `route()`, catch untouched — DECIDED.**
   The governing principle (settled in review): **two channels for problems.** `pkg.result` carries *known/handled* conditions — detect, record a coded `KJ_Tool_Exception`, return normally. The `try/catch` is the net for *unexpected* failures — one catch, wrap generically, append. You don't throw to communicate a handled condition; you record it. (Rejected en route: a split/preserving catch and a `requireTriggerContext` throw-helper — both were exception-as-control-flow ceremony solving a problem that doesn't exist, since nothing throws a coded exception inside the try and nothing should.)
   *This dissolves the earlier "thrown-LOW reads as success" question* — we don't throw non-fatal coded exceptions at all.

   *Open, non-blocking:* now that `buildPackage()` is also inside the try, the catch-all means "any unexpected pipeline failure," and `ROUTING_ERROR` reads narrower than that. **Defaulting to keep `ROUTING_ERROR`** (zero work); a rename to e.g. `UNHANDLED_ERROR` (enum + wherever codes get formatted) can come later if it grates.

3. **`KJ_Tool_TestDataFactory` is not `@isTest`** — deployable code that itself needs coverage. Not urgent; flagging the maintainability papercut.

*Explicitly deferred:* failure *policy* (does a before-trigger fatal `addError()` to block the save?), `Engine.md`, the `KJ_Model` question.

## 5. What I'm Cutting (and why)

- **#3 (mislabeled error) — PULLED INTO SCOPE**, no longer a cut. Now Block A2 #3 (the `route()` guard).
- **#5 `didFieldChange()` NPE on insert** — real (`oldMap` empty on insert → `oldRecord.get()` NPEs), but dormant; no update logic today. Carries with the engine work.
- **Real engine business logic** — the spike is about the *template*, not lead rules. A throwing stub proves the failure lane. Highest-value cut.
- **Docs (`Engine.md`), `KJ_Model`** — carry.

## 6. Cut Line

Banked-on-early-stop order: **A1 green+commit → A2 green+commit → Block B failure proof → C/D.** An early stop after Block B still answers the spike's central question, which is the entire point of the spike. C and D are a pin and hygiene.

## 7. Day Checklist

- [ ] A1: deploy working tree to `KJHC_V2_Dev_Org` → green → commit the #2 hardening
- [ ] A2: `run()` returns `KJ_Tool_Package`
- [ ] A2: `LeadController.route()` guards null `triggerContext` → records `INVALID_CONTEXT`, returns (catch untouched) → deploy → green → commit
- [ ] Decide test home; create `tests/` folder(s)
- [ ] `KJ_Dispatch_AbstractController_Test` green: route-throws, buildPackage-throws, happy, invalid-context (real controller)
- [ ] `KJ_Tool_Result_Test` LOW-after-FATAL *(if time)*
- [ ] `git rm --cached kjhc.bundle` + ignore `*.bundle`
- [ ] Commit + EOD note (template holds under failure: yes/no?)

## 8. Definition of Done

The working tree compiles and deploys clean, and all changes are committed. `run()` returns its `KJ_Tool_Package`. A failure in `route()` **and** in `buildPackage()` both land on `result`, flip `isSuccess` false, and log at error. A **non-trigger invocation lands as `INVALID_CONTEXT`** (not a generic wrap), via a precondition guard in `route()` — the catch stays a single generic net. A green test asserts all of it — closing the spike's central question: the template holds under failure, not just success.

---

*(EOD note goes here)*
