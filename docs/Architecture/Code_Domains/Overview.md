Below is a diagram of a basic view of how data flows through the orgs domain structure

External World
      │
      ▼
┌─────────────────────────────────────────┐
│  ENTRY POINTS (where signals come from) │
│  UI → user action                       │
│  Integration → external system event    │
│  Exec → manual/scheduled trigger        │
└─────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────┐
│  KJ_Dispatch (entry point layer)        │
│  Trigger Handlers                       │
│  Schedulers                             │
│  NO logic. Validates context,           │
│  calls Engine, logs via Tool            │
└─────────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────────┐
│  KJ_ENGINE (logic layer)                │
│  Does the actual work                   │
│  May call Integration for external ops  │
│  Uses Tool heavily throughout           │
└─────────────────────────────────────────┘
      │                    │
      ▼                    ▼
┌──────────────┐   ┌───────────────────┐
│ KJ_MODEL     │   │ KJ_INTEGRATION    │
│ Wrappers,    │   │ Called by Engine  │
│ DTOs         │   │ when external I/O │
│              │   │ is needed         │
└──────────────┘   └───────────────────┘

KJ_TOOL sits beneath ALL of this. every layer uses it.