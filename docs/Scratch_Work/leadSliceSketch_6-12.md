# Lead Slice — Day Sketch (6/12/2026)

## 1. Yesterday's Plan vs. What Landed

Yesterday's plan ran six blocks. Here's the reconciliation:

| Block | Plan | Outcome |
|---|---|---|
| 8:30–9:15 | Stabilize + baseline commit | ✅ `8f05200` (08:37). Deleted tests committed as deleted — restructure accepted. |
| 9:15–10:30 | Finish AbstractController contract | ✅ `9c79137` (09:46). Catch wraps via `fatal(Exception, Code)`; finalize maps FATAL→error, else→warn. |
| 10:30–12:00 | Wire the slice + one real engine rule | ⚠️ Trigger + `route()` done. **The real engine rule was swapped for a `Logger.debug()` marker** — engine still does nothing. |
| 12:30–2:00 | Deploy, prove 3 things | ⚠️ 17 deploy errors → 3 root causes fixed → **happy path proven 12:24** (`04dd5f2`). Contexts populate ✅. **Forced-exception path never tested** — the failure lane is unproven. |
| 2:00–3:00 | Tests | ❌ Not reached. Repo has zero test classes. |
| 3:00–3:30 | Findings note in Scratch_Work | ❌ Not written. (This doc absorbs it — see §3.) |

The day ended at the proof moment (~12:25 final commit). So today inherits three things outright: **the real engine rule, the failure-lane proof, and tests** — plus the docs catch-up.

Also queued from yesterday's wrap-up: the **internal-origin dispatch call** (engine → other controller) as the natural next spike. Not today — today finishes this one.

## 2. Where the Spike Stands

```
[KJ_Dispatch_LeadTrigger]            (before insert, before update)
        │
        ▼
[KJ_Dispatch_LeadController.run()]   ← inherited from AbstractController
        │  buildPackage() → route() → finalize()
        ▼
[KJ_Engine_LeadEngine]               onBeforeInsert / onBeforeUpdate
        │
        └──► currently: debug logging only
```

Proven in the scratch org (debug log, 6/11 12:24): trigger fired on BeforeUpdate → controller → `buildPackage()` (OrgContext SOQL populated) → `route()` → engine debug line → clean exit, zero exceptions.

**Not yet proven:** the unhappy path. No run has ever exercised catch → `KJ_Tool_Exception.fatal(e, ROUTING_ERROR)` → `result.addException()` → `finalize()` logging. That lane is the half of the controller contract the spike exists to validate.

## 3. Morning Review Findings (fix-first list)

1.  **`KJ_Tool_Result.addException()` can resurrect success — and yesterday's wrap-up assumed the opposite.** Yesterday's session signed off on the AbstractController on the basis that "addException() handles the success-flag flipping properly." It doesn't, quite: the `when LOW` branch sets `isSuccess = true` unconditionally, so a LOW added *after* a FATAL flips the package back to successful — and `finalize()` then early-returns and never logs the fatal. Same flaw in `addExceptions()`. (`updateFlags()` has the corrective final check; the add paths don't.) Fix: add paths only ever set `isSuccess = false`. This lands before the failure-lane proof, or the proof can lie.
2.  **`buildPackage()` sits outside the try in `run()`.** If context building throws (e.g. the UserContext SOQL), the raw exception escapes straight to the trigger — no wrapping, no logging.
3.  **Non-trigger invocation NPEs.** `TriggerContext.build()` returns null outside a trigger (good), but `LeadController.route()` dereferences `ctx.isBefore` immediately. Anonymous Apex or a future UI/internal origin dies as a misleading ROUTING_ERROR. First brick of the internal-origin lane.
4.  **Wrapped exceptions carry an empty message.** The `(Exception, Code)` overloads leave `message = ''`. The formatter compensates with `Caused by:` + stack trace, but `message` should default to `nativeException.getMessage()`.
5.  **`TriggerContext.didFieldChange()` NPEs in insert context** (`oldMap` null) and assumes the record exists in both maps. It gets exercised the moment the engine does real update logic — guard it now.
6.  **No proof harness.** `KJ_Tool_TestDataFactory` survives, but nothing tests the dispatch path. "Mock Engine Tests" from the original controller roadmap is still open.

**Deploy gotchas worth remembering** (yesterday's 17-error cascade, 3 root causes — these are environment rules, not one-off typos): Exception subclasses can't redeclare the no-arg constructor; inner enum values need full qualification (`KJ_Tool_LogEntry.Level.DEBUG`) in constructors; `List.getFirst()/getLast()` aren't available. New code should respect all three.

## 4. Today's Plan (8:30–3:30)

**Theme: the slice carries real cargo, and proves it both ways.** Yesterday proved the pipes on the happy path. Today: real business behavior rides them, the failure lane gets exercised once on purpose, and tests pin all of it down.

**8:30 – 9:00 — Patch the result lane, baseline commit.**
Findings #1 and #4 (the success-flag bug and the empty wrapped message), plus the `didFieldChange()` guards (#5) and the null-triggerContext guard (#3 — fail fast with a clear code, `INVALID_CONTEXT` or similar, per design question 3). Commit. Everything after this trusts `result.isSuccess`, so it goes first.

**9:00 – 10:15 — First real engine behavior** *(carry-over)*.
`onBeforeInsert`: pick one or two boring, observable rules on real Lead fields — default `Job_Project_Priority_Level__c` when blank; default `Contact_Method_Preference__c` from presence of Phone vs Email; or stamp `Branch_Territory__c`. `onBeforeUpdate`: one field-change reaction using `getChangedRecords()` (e.g. react when `Sector__c` changes) — this forces the #5 guards to be real.

**10:15 – 11:00 — Prove the failure lane** *(carry-over — the unproven third of yesterday's deploy block)*.
Deploy, then force an engine exception (temporary throw) and watch it land: wrapped as ROUTING_ERROR → `result` flips unsuccessful → `finalize()` logs at ERROR. Then settle design question 1 (failure policy): if adopted, wire the `addError()` hook and watch a fatal actually block a save. Remove the forced throw.

**11:00 – 12:00 — Tests, part 1.**
Settle design question 4 (test home) *first* so files don't move twice. Then `KJ_Engine_LeadEngine_Test`: insert/update Leads via `KJ_Tool_TestDataFactory`, assert the engine's field effects — DML fires the real trigger, so this covers trigger → controller → engine for free.

**12:00 – 12:30 — Break / lunch.**

**12:30 – 1:45 — Tests, part 2.**
`KJ_Dispatch_AbstractController_Test` with a throwing stub controller: asserts the ROUTING_ERROR wrap, the result flags (including the LOW-after-FATAL case from finding #1 — regression-pin the morning's fix), and finalize behavior. Full deploy + test run in the org.

**1:45 – 2:45 — Docs catch-up** *(carry-over)*.
The findings note that didn't get written yesterday is this doc's §1–§3 — extract the durable parts: one paragraph in `KJ_Engine/docs/Engine.md` (currently empty) stating the engine contract (per design question 2), and the test-home decision into `docs/Standards/File_and_Folder_Structure.md`.

**2:45 – 3:30 — Wrap-up.**
Commit. Short EOD note at the bottom of this doc: what held, what broke, and a yes/no on whether the AbstractController template is ready to stamp out for the next object. Queue tomorrow's decision (see Key Question).

**Ordering rule for the day** (yesterday's rule held up — same spirit): don't write engine logic against a result lane you don't trust — the Result patch goes first, and the failure-lane proof happens *before* the test suite gets built on top of it.

**Cut line:** historically the final commit lands ~12:30, even when the stated day runs to 3:30. The blocks are ordered so that an early stop still banks the essentials — patch, real behavior, failure proof. If the afternoon happens, it's tests and docs; if it doesn't, those carry to tomorrow's sketch *again*, which is its own signal.

## 5. Design Questions to Settle Today

1.  **Failure policy.** A FATAL in a before-trigger currently logs and *lets the save commit*. Options: (a) log-only, (b) `addError()` on affected records to block the save, (c) policy flag on the package/controller. Recommendation: before-context fatals should `addError()` — silent commits after a fatal are the kind of thing you discover months later. Make it a virtual hook on the abstract controller so per-object controllers can opt out.
2.  **Engine contract.** Engines currently mutate `pkg` (records + result) and return void. Is that the convention — "engines report through the package, never return"? If yes, write it into Engine.md so the next engine copies the right shape.
3.  **Non-trigger entry guard.** Should the abstract `run()` check context validity before routing, or should each `route()` guard itself? Abstract-level check is one fix in one place; per-route guards allow controllers that legitimately serve multiple origins later. Leaning abstract-level for now — it can devolve later when the internal-origin lane gets built.
4.  **Where do tests live?** `KJ_Tool/test/` was deleted and was never a registered package directory. Options: (a) `<segment>/test/` registered in sfdx-project.json, (b) `<segment>/main/default/classes/tests/` inside existing dirs. (b) deploys without config changes; (a) keeps test code out of the deployable main line. Pick one, document it.

## 6. Day Checklist

- [ ] Fix `KJ_Tool_Result.addException()` / `addExceptions()` success-flag bug
- [ ] Default wrapped exception message to `nativeException.getMessage()`
- [ ] Guard `didFieldChange()` / `getChangedRecords()` for insert context + missing records
- [ ] Null-triggerContext guard with honest error code (question 3)
- [ ] Baseline commit
- [ ] Real before-insert behavior in `KJ_Engine_LeadEngine` *(carry-over)*
- [ ] One before-update field-change reaction *(carry-over)*
- [ ] Force an engine exception in the org; verify wrap → result → finalize logging *(carry-over)*
- [ ] Decide failure policy; wire `addError()` hook if adopted
- [ ] Decide test home; document it
- [ ] `KJ_Engine_LeadEngine_Test` green *(carry-over)*
- [ ] `KJ_Dispatch_AbstractController_Test` green, incl. LOW-after-FATAL regression case *(carry-over)*
- [ ] Engine contract paragraph in `KJ_Engine/docs/Engine.md`
- [ ] EOD note at the bottom of this doc

## 7. Definition of Done

Insert a Lead: the trigger fires, the engine visibly mutates the record, `pkg.result` reflects reality, and a green test asserts all of it. Force one engine failure: it's wrapped, flagged, logged at the right level — and, if the policy is adopted, the save is blocked. Both lanes proven, both pinned by tests. That closes the spike's actual question: *does the AbstractController template hold under success and failure?*

---

### Key Question for the Next Conversation

Two queued, pick the order tomorrow:

1.  **Internal-origin dispatch** (engine → other controller) — yesterday's wrap-up nominated this as the natural next spike once the slice holds.
2.  **What is KJ_Model?** When the engine starts making *decisions* (lead routing by `Branch_Territory__c` / `Sector__c`), does that configuration live in code, Custom Metadata, or KJ_Model? Model.md is still empty; this answer is what fills it.

These may be the same question approached from two ends — the internal-origin lane needs to know where routing knowledge lives, and that's the KJ_Model question wearing a different hat.

---

*(EOD note goes here)*
