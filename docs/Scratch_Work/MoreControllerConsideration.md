

his is a great architectural question. Let me think through it carefully before giving you a recommendation.

The Core Tension
The question of engine-to-engine communication is really asking: who owns orchestration?

Two valid philosophies:

Dispatch owns everything — all cross-object coordination routes through controllers. Engines are pure logic boxes that never know about each other.

Engines can talk directly — dispatch handles external entry, but engines can call each other internally as a "private" channel.

My Recommendation: Dispatch Owns Everything
Here's why:

Controllers as static routers is the right call — and the logical conclusion of that pattern is that all routing happens there, including engine-to-engine calls. The moment you let engines reach each other directly, you've created a second, unofficial dispatch layer that lives inside the engine domain. That hidden coupling will grow.

The practical solution is to distinguish between two types of dispatch calls:

External calls — triggered by UI, Integration, Triggers. These are the obvious ones.
Internal calls — one engine needs a result from another. These still go through dispatch, but they're flagged as internal origin (you already have an Origin Framework, so this fits naturally).
This gives you a clean rule: nothing enters an engine except through its controller, period.

What This Looks Like in Practice
[Trigger / UI / Integration]
        │
        ▼
  [Controller A]  ← static, routes by object
        │
        ▼
  [Engine A]
        │
        │  needs Account data/logic
        │
        ▼
  [Controller B]  ← same dispatch layer, internal origin
        │
        ▼
  [Engine B]
        │
        └──► Result back up the chain
Engine A never imports or calls Engine B. It calls AccountController.resolve(context) the same way a trigger would — just with an internal origin marker.

Controller Class Design Considerations
Since you're leaning static, a few things worth thinking through:

What a controller is responsible for:

Receiving the triggering event + context
Determining which engine method to invoke (routing logic)
Packaging the result back to the caller
What it is NOT responsible for:

Any business logic (that belongs in the engine)
Knowing about other controllers (engines ask, dispatch routes)
Static works well here because:

Controllers don't hold state — they're pure routers
All callers (triggers, UI, integration, other engines) get the same entry point
Easy to mock/stub in your Testing Framework
A rough structure might look like:

apex
public class OpportunityController {
    public static Result route(KJContext ctx, KJEvent event) {
        // resolve origin (trigger? UI? internal engine call?)
        // delegate to engine
        // return result
    }
}
Key Question for the Next Conversation
Before you start designing the first controller class, I'd nail down: what does "routing" actually mean here?

Is the controller making a decision (if event is X, call engine method Y), or is it purely a pass-through that lets the engine decide what to do with a context + event? The answer shapes how much logic lives in the controller vs. the engine, and whether controllers need conditional branching or can stay thin.