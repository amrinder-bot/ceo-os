# CEO OS

A private, single-user executive command center for iPhone (then iPad, Mac, Apple Watch).

Native Apple stack: Swift · SwiftUI · SwiftData · CloudKit · EventKit · App Intents · UserNotifications · WidgetKit.

## Status

**Design phase.** No application code yet. Architecture v1.1 — all blocking questions resolved (see the Decisions table in the doc); Phase 0 is unblocked.

## Settled decisions

- **iOS 26 minimum**, single user. Unlocks on-device Foundation Models for private AI.
- **Google Calendar is read through EventKit** (Workspace account added in iOS Settings), not the Google API. Removes OAuth, token storage, and the duplication problem from the roadmap.
- **Team access is a likely future.** Phase 1 stays single-user on CloudKit private; six forward-compatibility hooks land in schema v1.

## Documents

- [`docs/01-architecture.md`](docs/01-architecture.md) — product architecture, technical architecture, data model, screen map, sync/source-of-truth strategy, Siri architecture, notification logic, build order, risks, and open questions.

## Core idea

Every surface in the app — dashboard, notifications, morning brief, widget, AI answers — renders the output of one deterministic **Attention Engine**. One signal source, many surfaces, fully explainable, no scoring model.

## Next step

Answer Section 11 of the architecture document, then begin Phase 0 (project foundations).
