This is a very strong architectural foundation. The separation you have defined—specifically the distinction
between **KJ Engine** (Business Logic) and **KJ Dispatch** (Orchestration/Triggers)—is the "Holy Grail" of
scalable Salesforce development.

You are moving away from the anti-pattern of "God Triggers" that call business logic directly. You are moving
toward a **Mediator/Dispatcher Pattern**, which is exactly what the **Dispatch** domain is supposed to do.

Here is my review of your architecture and a roadmap for exactly what you need to develop next, specifically
regarding the Controller Framework in **KJ Dispatch**.

---

### 1. Architecture Review: Is the Controller Framework the Right Move?

**Verdict:** **Yes.**
Placing the controller/framework in **KJ Dispatch** is the correct next step for the following reasons:

*   **Decoupling:** It separates *When* to run code (Dispatch/Trigger) from *What* code to run (Engine).
*   **Maintainability:** If business logic changes, you only touch `KJ Engine`, not the trigger files.
*   **Testing:** You can unit test logic engines in isolation. You don't need to fire actual Apex Triggers to test
the logic; you can simulate the dispatch event.
*   **Governor Limit Safety:** By forcing all logic through a central Controller, you ensure that exception
handling, logging, and transaction safety (via KJ Tool frameworks) are applied uniformly.

### 2. What to Develop Next: The Implementation Roadmap

To make the **Dispatch Controller Framework** functional, you need to build the bridge between the raw Salesforce
Trigger (Event) and the KJ Engine (Logic). Here is the step-by-step breakdown:

#### Phase 1: Define the Contract (KJ Model & KJ Tool)
Before the Controller calls the Engines, they must agree on a language.
*   **Develop:** **Logic Engine Interface.**
    *   Create an Apex `interface` that every logic engine must implement (e.g., `IObjectLogicHandler`).
    *   **Key Method:** `void process(TriggerContext context)` or similar.
    *   **Key Requirement:** These interfaces must utilize `KJ Context Framework` and `KJ Result Framework` for
data in/out.
*   **Why:** If the Engine logic changes (e.g., renaming an object or method), the Controller doesn't break.

#### Phase 2: The Routing Registry (KJ Dispatch Core)
The Controller needs a way to know *which* Engine to call for *which* Object or Event.
*   **Develop:** **Trigger Event Registry.**
    *   Map Object Types (e.g., `Account`, `Case`) and Trigger Events (e.g., `INSERT`, `UPDATE`) to specific
Interface implementations.
    *   **Implementation:** This should be a simple JSON-based configuration class or a `List<LogicRoute>` managed
class so you don't have hard-coded routing in the Controller.
*   **Why:** This allows you to toggle logic without code deployment (if you add an `@AuraEnabled` configuration
or use Metadata API settings later).

#### Phase 3: The Controller Implementation (KJ Dispatch)
This is the core of your request.
*   **Develop:** **Trigger Handler Class.**
    *   **Responsibility:** Do **not** put business logic here.
    *   **Responsibility:** Validate context (User, Org ID).
    *   **Responsibility:** Iterate over the Registry and dispatch the event to the specific Logic Engine.
*   **Development:** **Exception Handling Layer.**
    *   Use your **KJ Exception Framework**. If Engine A fails, Dispatch should not fail the transaction
immediately unless critical. It should log the exception and allow the process to continue to Engine B if they are
parallel operations.

#### Phase 4: Asynchronous Logic Support (KJ Execute / Integrate)
You mentioned "KJ Execute" for direct execution.
*   **Consideration:** If a Logic Engine requires a process that takes longer than governor limits (e.g., sending
email, external API call), the Controller in Dispatch must route this to **KJ Execute** (Queue) rather than **KJ
Engine** (Sync).
*   **Develop:** **Async Decision Logic** within the Dispatch Controller.
    *   Ask the Engine: "Can this be processed synchronously?"
    *   If No -> Send to Queue/Execute.
    *   If Yes -> Call Engine.
KJ_Toole_Design theo
---

### 3. Critical Technical Considerations for Your Controller

As you build the Controller Framework in **KJ Dispatch**, keep these three constraints in mind to avoid
re-architecture headaches later:

1.  **Context Propagation:**
    *   Ensure your **KJ Context Framework** is threaded through the Dispatch Controller. Every Logic Engine needs
to know the `UserId`, `SessionId`, `OrgId`, and `TenantId`. Do not let the Engine assume these values.
2.  **Trigger Context Handling:**
    *   Apex Triggers provide `Map<SObject, Object>` collections. The Controller must extract the necessary IDs
from these collections *before* sending to the Engine.
    *   *Recommendation:* Create a `DispatchEvent` wrapper class that encapsulates `List<SObject>` and
`List<String> Ids`.
3.  **Order of Operations:**
    *   Your Controller must define if Logic Engines run **Parallel** or **Sequential**.
    *   *Recommendation:* Default to Sequential within a transaction, but use Parallel for things like validation
(pre-save) vs. enrichment (post-save).public with sharing class KJ_Tool_TriggerContext {
    //*-- Member Variables ------------------------------------------------------------------------
    public Boolean isAfter      { get; private set; }
    public Boolean isBefore     { get; private set; }

    public Boolean isInsert     { get; private set; }
    public Boolean isUpdate     { get; private set; }
    public Boolean isDelete     { get; private set; }
    public Boolean isUndelete   { get; private set; }

    public List<SObject> newList    { get; private set; }
    public List<SObject> oldList    { get; private set; }
    public Map<Id, SObject> newMap  { get; private set; }
    public Map<Id, SObject> oldMap  { get; private set; }

    //*-- Member Methods --------------------------------------------------------------------------
    // Factory method
    public static KJ_Tool_TriggerContext build(){
        KJ_Tool_TriggerContext newContext = new KJ_Tool_TriggerContext();

        newContext.isBefore = Trigger.isBefore;
        newContext.isAfter = Trigger.isAfter;

        newContext.isInsert = Trigger.isInsert; 
        newContext.isUpdate = Trigger.isUpdate;
        newContext.isDelete = Trigger.isDelete;
        newContext.isUndelete = Trigger.isUndelete;

        newContext.newList = Trigger.new;
        newContext.oldList = Trigger.old;
        newContext.newMap = Trigger.newMap;
        newContext.oldMap = Trigger.oldMap;

        return newContext;
    }

    // Returns whether specified field has changed on specified record
    public Boolean didFieldChange(Id targetRecordId, schema.SObjectField targetField){
        SObject newRecord = newMap.get(targetRecordId);
        SObject oldRecord = oldMap.get(targetRecordId);

        Boolean result = newRecord.get(targetField) != oldRecord.get(targetField);

        return result;
    }
    
    // Returns list of records that had their specified field changed
    public List<SObject> getChangedRecords(Schema.SObjectField targetField){
        List<SObject> changedRecords = new List<SObject>();

        for(SObject currentRecord : newList) {
            if (didFieldChange(currentRecord.Id, targetField)){
                changedRecords.add(currentRecord);
            }
        }

        return changedRecords;
    }

}

---

### 4. Summary Checklist for Your Next Sprint

If I were leading this effort, here is my list of deliverables for your next iteration:

1.  [ ] **KJ LogicEngine Interface** (Define the contract for business logic).
2.  [ ] **KJ Context Wrapper** (Ensure logic engines receive transactional context).
3.  [ ] **KJ Dispatcher Class** (The Controller that reads the Registry).
4.  [ ] **Mock Engine Tests** (Verify the Controller calls the right Engine when a specific Object/Event is
fired).
5.  [ ] **Error Mapping** (Map Engine Exceptions to the KJ Exception Framework codes).

### Final Recommendation
**Stick to this plan.** Do not build complex business logic in the Trigger. Do not build complex logic in the UI.
Do not build complex logic in Integrations.

Build a **Dispatch Controller** that simply asks: *"I have data about a [Object], what Logic Engine handles
this?"*

That is the correct definition of the **Dispatch** domain. Start with defining the **Interface Contracts** for the
Engines first, then build the Controller to consume them.

**Ready to start?** I recommend you document the `LogicEngineInterface` signature today, as that dictates your
Controller design.