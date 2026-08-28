# CEO OS — Product & Technical Architecture

**Version:** 1.0 (pre-implementation)
**Platform:** iOS first (iPhone), then iPad / Mac / Apple Watch
**Status:** Design document. No code written yet.

---

## SECTION 1 — PRODUCT SUMMARY

### What CEO OS is

CEO OS is a private, single-user executive command center. It is not a project-management tool that you administer. It is a system that **absorbs everything you know, and hands it back to you at the moment it matters.**

The product has exactly two jobs:

1. **Capture is frictionless.** Anything in your head goes in within five seconds — by voice, by Siri, from the Lock Screen, mid-meeting — without you choosing a project, a list, or a due date first.
2. **Retrieval is automatic.** You never search for what you forgot. The system surfaces it: the overdue thing you delegated, the project that has gone quiet, the decision that has been sitting on you for nine days, the person who owes you a number.

Everything else in this document exists to serve those two jobs.

### The core mental model

There is one idea that the whole system is built on:

> **Every surface in CEO OS is a different view of the same signal.**

A single deterministic component — the **Attention Engine** — evaluates your entire database against explainable rules and produces a ranked list of `AttentionSignal`s: *"XPro Health Website is At Risk because Milestone 3 is 4 days overdue and there has been no project update in 8 days."*

That one list then drives:

| Surface | What it does with the signals |
|---|---|
| CEO Dashboard "Attention Required" | Renders the top signals |
| Notifications | Fires on the few signals that pass the interruption budget |
| Morning Brief | Summarises today's signals |
| End of Day Review | Shows what is still unresolved |
| Weekly Review | Shows structural gaps (missing owner, missing deadline) |
| Widget / Lock Screen | Shows the single highest signal |
| AI Chief of Staff | Answers "what am I forgetting?" by citing signals |

This is why the build order below puts the Attention Engine *before* the dashboard. If each surface computes its own version of "what matters," they will disagree with each other, and you will stop trusting the app. One engine, many surfaces.

### What CEO OS deliberately is not

- **Not a Notes replacement.** It has its own structured database. Apple Notes is not a data store.
- **Not a team tool (yet).** Phase 1 is one user, private CloudKit database. Collaboration is a real re-architecture, not a feature flag — see Risks.
- **Not a metrics dashboard.** No burndown charts. No velocity. Company Pulse is four numbers, not forty.
- **Not an AI oracle.** The AI never invents a fact. It queries your records and cites them, or it says it does not know.

### The five-second test

Every design decision is judged against this: *open the app cold, and within five seconds know what needs to be done, where to be, what needs attention, what you are waiting on, what is behind, and what to focus on.* If a feature does not serve that, it goes behind progressive disclosure or does not get built.

---

## SECTION 2 — USER EXPERIENCE (a day in CEO OS)

### 6:45 AM — Wake

A single notification:

```
CEO BRIEF
6 meetings · 3 priorities · 2 items need you
```

Tapping it opens the **Morning Brief** — a full-screen, scrollable card, not a dashboard. It reads in about twenty seconds:

```
GOOD MORNING

TODAY          6 meetings · 3 priorities · 8 tasks
FIRST          Investor call — 9:00 AM (in 2h 15m)
FREE           11:30–1:00, 3:30–5:00

ATTENTION
  2 delegated items overdue
  1 project at risk — XPro Health Website
  1 decision required — Kamboj Ventures acquisition (9 days)

TOP 3
  1. Review XPro Health location
  2. Approve Kamboj Ventures acquisition
  3. Review sales numbers

WAITING
  Rafael — lease numbers (2 days late)
  Aaron — weekly sales report (due today)

UPCOMING
  9:00  Investor call
  11:00 XPro Vault packaging
  2:30  XPro Health review
```

At the bottom: **Confirm Top 3** — one tap. The system proposes them from the Attention Engine; you can swap any of them. That single tap is the entire daily planning ritual. The confirmed Top 3 is what the widget, the Lock Screen, and the shutdown review measure against.

### 7:30 AM — Car

You hold the side button:

> *"Hey Siri, add a task to follow up with Aaron Friday."*

Siri confirms out loud: *"Follow-up with Aaron, Friday."* Nothing opens. Nothing is organised. The item lands as a **Follow-up**, person = Aaron (matched against your People records), due Friday. If the parser was not confident about the person, it still saves — with an "unconfirmed" chip — and appears in the Inbox for a one-tap fix later. **Capture never fails and never blocks.**

### 9:00 AM — Investor call

The meeting is already in CEO OS because it is on your calendar. It was auto-linked to *Kamboj Capital Solutions* because two attendees are People on that company. On the meeting screen: your prep notes, the three open items with these attendees, and the last decision you made with them.

During the call you tap **Capture** twice — voice, five seconds each.

### 9:45 AM — Meeting debrief

The meeting screen shows a **Debrief** button while the event is still on screen. Four fields, all optional, all one tap to skip:

- **Decisions** → creates Decision records, pre-filled with company/project/attendees
- **Tasks** → yours
- **Delegations** → theirs, with a follow-up date defaulted to due date minus one day
- **Follow-ups** → things to circle back on

This is the highest-leverage screen in the product. Most delegation loss happens in the ten minutes after a meeting.

### 11:30 AM — Focus

The calendar shows a gap. You tap **Protect this** on the gap and it becomes a Focus Block: a real calendar event written to a dedicated **CEO OS** calendar (never to your work or shared calendars), pre-labelled with the Top 3 item you are working on. If someone books over it, CEO OS raises a conflict signal rather than silently letting it be eaten.

### 2:30 PM — XPro Health review

Project screen shows: owner, health, next milestone, blocker, last update, next action — six lines, above the fold. Below, progressively disclosed: tasks, decisions, updates, related meetings.

You tap **Post Update**, dictate three sentences, and set percent complete. That single act clears the "no update in 8 days" signal and is what keeps project health honest. Updates are append-only — they are never edited away, so the project has a real history.

### 6:30 PM — Shutdown

```
SHUTDOWN REVIEW

DONE TODAY            7 tasks · 2 of 3 priorities
UNFINISHED            1 priority — Review sales numbers
NEW SINCE THIS MORNING 4 captures, 2 unfiled
OVERDUE               3 tasks
STILL WAITING         Rafael — lease numbers (3 days)
TOMORROW              4 meetings · first at 8:30
PROPOSED TOP 3        …
```

Every unfinished item has three buttons: **Tomorrow · Delegate · Drop**. The review is designed to be completed in under ninety seconds. Its purpose is to make sure nothing rolls silently into tomorrow.

### Friday 4:00 PM — Weekly review

A guided sequence, one company at a time. For every active project the system asks the same four questions: **owner, deadline, next action, blocker.** Anything missing is flagged. This is what stops projects drifting for a month without anyone noticing.

---

## SECTION 3 — SCREEN MAP

Navigation: five tabs — **Home · Projects · Capture · Tasks · More**. Capture is the centre tab and also a floating action available from every screen.

### Primary

| # | Screen | Purpose |
|---|---|---|
| 1 | **Home / CEO Dashboard** | Today · Top 3 · Attention Required · Waiting On · Today's Tasks · Company Pulse. Answers the five-second test. |
| 2 | **Capture Sheet** | Modal. Voice / text, type selector (Task, Idea, Note, Follow-up, Decision, Delegation). Saves instantly. |
| 3 | **Capture Confirmation** | Post-parse review: shows extracted type, person, company, project, date. Editable. Auto-dismisses after 3s if confident. |
| 4 | **Inbox** | Unprocessed or low-confidence captures. Should normally be empty. |
| 5 | **Projects** | Grouped by company. Health-coloured. Filters: at-risk, mine, stale, all. |
| 6 | **Project Detail** | Header (owner, health, next milestone, next action, blocker, last update) then tabs: Tasks · Updates · Decisions · Milestones · Meetings · Notes. |
| 7 | **Project Update Composer** | Voice or text + percent complete + health confirm. |
| 8 | **Tasks** | Segmented: Today · Upcoming · Overdue · This Week · Someday · Completed. |
| 9 | **Task Detail** | Full field editor + Reminder mirror toggle. |
| 10 | **Waiting On** | "Who owes me what." Delegations + external follow-ups, sorted by lateness. |
| 11 | **Delegated** | Everything you assigned, by status and by person. |
| 12 | **Delegation Detail** | What, who, dates, status timeline, nudge action. |
| 13 | **Today's Schedule** | Merged Apple + Google calendar day view with conflicts and free gaps. |
| 14 | **Focus Block Composer** | Time, duration, linked priority. Writes to CEO OS calendar. |
| 15 | **Morning Brief** | Full-screen daily brief + Confirm Top 3. |
| 16 | **End of Day Review** | Guided shutdown with Tomorrow / Delegate / Drop. |
| 17 | **Global Search** | Across every entity type, grouped by type, recent-first. |

### Secondary (under More)

| # | Screen | Purpose |
|---|---|---|
| 18 | **Ideas** | Capture-only list, filter by company/topic. Promote-to-project action. |
| 19 | **Notes** | Longer-form, linked to company/project/person/meeting. |
| 20 | **Decisions** | Log + a **Decision Required** queue (pending decisions with age). |
| 21 | **Meetings** | Calendar-derived, with prep/debrief state. |
| 22 | **Companies** | List + Company Detail: pulse, projects, people, open items. |
| 23 | **People** | List + Person Detail: "what is Rafael working on / owes me." |
| 24 | **Goals** | Quarterly/annual, linked to projects. |
| 25 | **Settings** | General · Companies · Notifications · Calendars · Reminders · Integrations · Security · Data & Diagnostics. |

### System / state screens (built in Phase 0, not bolted on later)

| # | Screen | Purpose |
|---|---|---|
| 26 | **App Lock** | Face ID / passcode gate. |
| 27 | **Permission Request & Denied** | Distinct, non-blocking states for Calendar, Reminders, Notifications, Speech, Contacts. The app must be fully usable with every permission denied. |
| 28 | **iCloud Unavailable** | Signed-out / storage-full / restricted. Local data remains editable. |
| 29 | **Offline Banner + Sync Status** | Pending-change count, last sync, manual retry. |
| 30 | **Diagnostics** | Sync log, external-link audit ("what CEO OS has written to your calendar and reminders"), export. |

### Phase 2+

| # | Screen | Purpose |
|---|---|---|
| 31 | **AI Chief of Staff** | Conversational, every answer citing records. |
| 32 | **Weekly Review** | Guided multi-step company/project sweep. |
| 33 | **Meeting Prep** | Pre-meeting briefing card. |

---

## SECTION 4 — DATA MODEL

### Modelling constraints (these shape everything)

SwiftData + CloudKit imposes hard rules. Violating them fails at runtime, not compile time, so the schema is designed around them from commit one:

1. Every property is **optional or has a default value**.
2. **No `@Attribute(.unique)`.** Uniqueness is enforced in application code on write, using a `uuid` property.
3. Every relationship is **optional and has a declared inverse**. No required to-one relationships.
4. **No custom merge policy.** CloudKit resolution is last-writer-wins per record.
5. Enums are stored as `String` raw values for schema stability.

Rule 4 is the important one, and it drives three deliberate modelling decisions:

- **Narrative content is append-only.** `ProjectUpdate`, `StatusHistory`, `CaptureItem` are never edited — so a sync conflict can never destroy text you wrote. Editing a project's `notes` from two devices can lose a paragraph; posting two updates from two devices loses nothing.
- **Derived state is never stored.** Project health, "overdue," risk, and attention signals are **computed on read**, never persisted as truth. Two devices can never disagree about health, because neither one stores it.
- **Records are fine-grained.** A Task and its Reminder link are separate records so that a mirror-sync write cannot clobber a title you just edited.

### Entities

Notation: `→` to-one, `⇉` to-many. All are optional per rule 3.

#### Core organisational

**UserProfile** *(single record)*
`displayName`, `workdayStart`, `workdayEnd`, `briefTime` (default 07:00), `shutdownTime` (default 18:00), `weeklyReviewWeekday` + `weeklyReviewTime`, `dailyNotificationBudget` (default 4), `appLockEnabled`, `appLockGracePeriod`, `defaultFocusBlockMinutes`, `aiTier` (off / onDevice / cloud), `ceoOSCalendarIdentifier`

**Company**
`uuid`, `name`, `shortName`, `colorHex`, `symbolName`, `isActive`, `sortOrder`, `notes`, `createdAt`, `archivedAt`
⇉ projects, people, tasks, ideas, notes, decisions, goals, delegations, followUps

**Person**
`uuid`, `name`, `role`, `email`, `phone`, `contactIdentifier` (CNContact id, optional), `isInternal`, `notes`, `createdAt`, `archivedAt`
→ primaryCompany · ⇉ companies, projectsOwned, projectsParticipating, delegations, followUps, decisionsInvolved, meetings

**Goal**
`uuid`, `title`, `horizon` (quarter/year), `targetDate`, `metricDescription`, `targetValue`, `currentValue`, `status`, `createdAt`
→ company · ⇉ projects

#### Work

**Project**
`uuid`, `name`, `priority` (critical/high/normal/low), `status` (idea/planned/active/paused/completed/cancelled), `startDate`, `targetDate`, `percentComplete` (0–100), `nextActionText`, `blockerText`, `blockerSince`, `nextReviewDate`, `notes`, `createdAt`, `completedAt`
`healthOverride` + `healthOverrideReason` + `healthOverrideExpiresAt` — manual override of computed health, **always time-boxed** so a stale override cannot hide a real problem forever
→ company, owner (Person) · ⇉ participants, milestones, tasks, updates, decisions, ideas, notes, meetings, delegations, followUps, goals, attachments

> **Health is not a stored field.** `Project.health` is a computed property derived from the Attention Engine. `healthOverride` is the only stored health-related value.

**Milestone**
`uuid`, `title`, `dueDate`, `completedAt`, `sortOrder`, `notes` · → project

**ProjectUpdate** *(append-only)*
`uuid`, `body`, `percentCompleteAtUpdate`, `computedHealthAtUpdate`, `createdAt`, `source` · → project, author

**StatusHistory** *(append-only)*
`uuid`, `subjectType`, `subjectUUID`, `field`, `oldValue`, `newValue`, `changedAt`, `changedBy`
Written only for project status/health and delegation status — enough for "when did this go sideways," not a full audit log.

**Task**
`uuid`, `title`, `details`, `priority`, `status` (inbox/next/scheduled/waiting/someday/done/cancelled), `dueDate`, `deferUntil`, `reminderAt`, `tags` `[String]`, `createdAt`, `completedAt`, `source` (manual/siri/capture/meeting/reminder/widget/watch), `estimatedMinutes`
→ company, project, milestone, relatedMeeting, relatedNote, originCapture, reminderLink (`ExternalReminderLink`)

**Delegation** — *things other people owe you*
`uuid`, `what`, `delegatedAt`, `dueDate`, `followUpDate`, `status` (delegated/acknowledged/inProgress/waiting/completed/cancelled), `lastNudgeAt`, `notes`, `completedAt`
→ assignedTo (Person), company, project, originCapture, relatedMeeting

> **`overdue` is not a status.** It is `dueDate < now && status ∉ {completed, cancelled}`, computed on read. This keeps the enum honest and means an unopened app can never show a wrong status.

**FollowUp** — *things you owe a conversation about*
`uuid`, `subject`, `dueDate`, `status`, `notes`, `createdAt`, `completedAt`, `recurrenceRule`
→ person, company, project, relatedMeeting, originCapture

#### Thinking

**Idea**
`uuid`, `title`, `body`, `topic`, `tags`, `status` (new/reviewing/promoted/archived), `createdAt`, `source`
→ company, project, person, promotedToProject, originCapture

**Note**
`uuid`, `title`, `body` (markdown), `tags`, `createdAt`, `updatedAt`
→ company, project, person, meeting, originCapture · ⇉ attachments

**Decision**
`uuid`, `title`, `status` (pending/decided/revisited/abandoned), `decidedOn`, `neededBy`, `context`, `rationale`, `alternativesConsidered`, `followUpRequired`, `createdAt`
→ company, project, resultingFollowUp · ⇉ peopleInvolved, supportingNotes

> The Decision entity does double duty: `status == .pending` **is** the "Decision Required" queue. There is no separate approvals model.

#### Time

**Meeting**
`uuid`, `title`, `startAt`, `endAt`, `location`, `prepNotes`, `notes`, `isPrepared`, `debriefCompletedAt`, `createdAt`
→ company, project, calendarEventLink · ⇉ attendees, tasksCreated, decisionsMade, followUpsCreated, delegationsCreated, notes

**CalendarEventLink** *(pointer + offline cache — never the source of truth for event content)*
`uuid`, `eventIdentifier` (EKEvent), `iCalUID`, `sourceSystem` (appleLocal/appleGoogleMirror/googleDirect), `calendarIdentifier`, `calendarTitle`, `googleEventID`, `googleCalendarID`, `recurrenceMasterUID`, `occurrenceStart`, `isCEOOSOwned`
Cached for offline display: `cachedTitle`, `cachedStart`, `cachedEnd`, `cachedIsAllDay`, `cachedLocation`, `cachedAttendeeCount`, `lastSyncedAt`
`fingerprint` — the dedup key (see Section 6)

**ExternalReminderLink**
`uuid`, `reminderIdentifier` (EKReminder calendarItemIdentifier), `externalIdentifier`, `listIdentifier`, `listTitle`, `direction` (mirrorOut/importedIn), `lastPushedFingerprint`, `lastPushedAt`, `lastPulledAt`, `syncState` (ok/conflict/detached/permissionLost)
→ task

#### System

**CaptureItem** *(append-only, the safety net)*
`uuid`, `rawText`, `transcript`, `audioFileName`, `capturedAt`, `source` (app/siri/widget/shareSheet/watch/lockScreen), `status` (unprocessed/proposed/confirmed/discarded), `proposalJSON`, `parserConfidence`, `materializedType`, `materializedUUID`, `processedAt`

**AttentionSignal** *(persisted only for dedup, snooze, and "new since")*
`uuid`, `signalKey` (stable hash of rule + subject), `ruleID`, `severity`, `subjectType`, `subjectUUID`, `explanation`, `evidenceUUIDs` `[String]`, `firstDetectedAt`, `lastSeenAt`, `resolvedAt`, `snoozedUntil`, `dismissedAt`, `lastNotifiedAt`, `notifyCount`

> The signal *evaluation* is stateless and recomputed every time. This record exists only so notifications can be deduped and snoozes can persist across devices.

**DailyPlan**
`uuid`, `date`, `briefGeneratedAt`, `briefOpenedAt`, `shutdownCompletedAt`, `notes` · ⇉ priorities

**PriorityItem** *(max 3 per DailyPlan)*
`uuid`, `sortOrder`, `title`, `linkedTaskUUID`, `linkedProjectUUID`, `linkedDecisionUUID`, `completedAt`
Uses UUID strings rather than polymorphic relationships, which SwiftData does not model well.

**NotificationRule**
`uuid`, `kind` (morningBrief/deadline/followUpDue/delegationOverdue/projectAtRisk/meetingPrep/decisionRequired/shutdown/weeklyReview), `enabled`, `level` (off/digestOnly/immediate), `fireTime`, `leadTimeMinutes`, `minimumSeverity`, `cooldownHours`, `maxPerDay`

**IntegrationAccount** — *no secrets in this record*
`uuid`, `provider` (google), `accountEmail`, `keychainAccount` (a **reference**, not a token), `grantedScopes`, `connectedAt`, `status`, `selectedCalendarIDs` `[String]`, `syncTokensJSON`, `lastSyncAt`, `lastError`

> Tokens live in the Keychain with `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` and are **explicitly excluded from iCloud Keychain sync**. Each device authenticates to Google independently. A synced OAuth token is a credential-spraying risk and a refresh-race bug.

**Attachment**
`uuid`, `filename`, `uti`, `fileData` (`@Attribute(.externalStorage)`), `thumbnailData`, `byteCount`, `createdAt` · → note, project, meeting, decision

### Relationship map

```
                        ┌─────────────┐
                        │   Company   │
                        └──────┬──────┘
        ┌──────────────┬───────┼────────┬──────────────┐
        ▼              ▼       ▼        ▼              ▼
    ┌────────┐   ┌─────────┐ ┌────┐ ┌────────┐   ┌──────────┐
    │ Person │   │ Project │ │Goal│ │  Idea  │   │ Decision │
    └───┬────┘   └────┬────┘ └────┘ └────────┘   └──────────┘
        │             │
        │      ┌──────┼──────┬──────────┬────────────┐
        │      ▼      ▼      ▼          ▼            ▼
        │  Milestone Task ProjectUpdate Note      Meeting
        │             │                              │
        │             │                    ┌─────────┴──────────┐
        │             ▼                    ▼                    ▼
        │   ExternalReminderLink   CalendarEventLink       (debrief →
        │                                                  Tasks /
        └──► Delegation ◄── "Waiting On" ──► FollowUp       Decisions /
                                                            Delegations)

  CaptureItem ──materialises into──► Task | Idea | Note | Decision
                                     | FollowUp | Delegation
```

---

## SECTION 5 — TECHNICAL ARCHITECTURE

### Layer diagram

```
┌───────────────────────────────────────────────────────────────┐
│  PRESENTATION            SwiftUI · WidgetKit · App Intents UI  │
│  Views are dumb. No business logic, no EventKit, no queries    │
│  more complex than a @Query with a predicate.                  │
├───────────────────────────────────────────────────────────────┤
│  DOMAIN SERVICES (pure Swift, no UI, fully unit-testable)      │
│  ┌──────────────┬───────────────┬────────────────────────────┐ │
│  │ AttentionEngine │ CaptureParser │ BriefBuilder            │ │
│  │ RiskRules[]     │ Classifier    │ ScheduleMerger          │ │
│  │ SearchService   │ PlanService   │ NotificationScheduler   │ │
│  └──────────────┴───────────────┴────────────────────────────┘ │
├───────────────────────────────────────────────────────────────┤
│  SYNC / INTEGRATION                                            │
│  CalendarService · ReminderMirror · GoogleCalendarClient       │
│  DedupResolver · ExternalLinkRegistry                          │
├───────────────────────────────────────────────────────────────┤
│  PERSISTENCE      SwiftData (App Group) ⇄ CloudKit private DB  │
│                   Keychain (tokens, never synced)              │
├───────────────────────────────────────────────────────────────┤
│  PLATFORM  EventKit · UserNotifications · LocalAuthentication  │
│            Speech · CoreSpotlight · FoundationModels · BGTask  │
└───────────────────────────────────────────────────────────────┘
```

The strict rule: **UI never touches EventKit, CloudKit, or the network directly.** Everything goes through a domain service. This is what makes widgets, App Intents, and the Watch app possible without duplicating logic — an App Intent calls `CaptureService.capture(text:)`, exactly as the UI does.

### Targets and shared code

| Target | Contents |
|---|---|
| `CEOOS` (app) | SwiftUI app |
| `CEOOSKit` (framework) | Models, domain services, integration layer — **all shared logic lives here** |
| `CEOOSWidgets` | WidgetKit extension |
| `CEOOSIntents` | App Intents extension (in-app intents where possible) |
| `CEOOSWatch` (Phase 3) | Watch app |

All targets share one **App Group** (`group.com.kamboj.ceoos`) so the SwiftData store is reachable from widgets and extensions.

> **This must be decided in commit one.** Moving a SwiftData + CloudKit store into an App Group container later means a file migration on a live synced database. This is the single most expensive thing to retrofit, and it is why "App Group + CloudKit container + entitlements" is step 0.1 of the build order.

### SwiftUI

- iOS 17+ observation (`@Observable`), `NavigationStack` with a **typed, `Codable` navigation path** so notifications, widgets, Spotlight results, and Siri can all deep-link to any record. A `DeepLinkRouter` translating `ceoos://project/<uuid>` into a path is built in Phase 0 — retrofitting deep links into an ad-hoc navigation structure is a rewrite.
- A real design system first: semantic colour tokens, a type ramp, spacing scale, and about a dozen shared components (`SignalRow`, `HealthBadge`, `EntityChip`, `SectionCard`, `EmptyState`, `PermissionGate`). Dark mode is designed first, not adapted.
- Lists are `@Query` with predicates and sort descriptors. Anything the Attention Engine computes is done in a service and passed in — never inside a `body`.

### SwiftData

- `VersionedSchema` + `SchemaMigrationPlan` from **v1**, even though v1 has nothing to migrate. Adding versioning after data exists is much harder.
- `ModelContainer` configured with the App Group URL and `cloudKitDatabase: .private("iCloud.com.kamboj.ceoos")`.
- Background work on a dedicated `ModelActor` — the Attention Engine sweep, dedup, and mirror sync never run on the main context.
- All CloudKit constraints from Section 4 enforced by a schema unit test that fails the build if a non-optional or unique attribute is introduced.

### CloudKit

- **Private database only.** No public or shared database in Phase 1–2.
- Sync is handled by SwiftData's CloudKit mirroring; the app does not write `CKRecord`s directly.
- **Offline-first by construction**: every write is local-first. The UI never waits on the network. The sync status is a passive indicator, not a blocking state.
- Conflict strategy: see Section 6.

### EventKit

Two separate authorisation surfaces with independent, non-blocking permission states:

- **Calendar** — request `.fullAccess` (needed to read existing events and detect conflicts). If only write access is granted, the app degrades gracefully: focus blocks still work; the schedule view shows a permission card.
- **Reminders** — `.full` required for the mirror. If denied, the Reminders toggle in Settings is disabled with an explanation, and everything else works.

Write discipline:

- CEO OS writes events **only to a calendar it created and owns**, titled "CEO OS". It never writes to your work, personal, shared, or Google-mirrored calendars.
- CEO OS **never modifies or deletes an event it did not create.** Every write is gated on `CalendarEventLink.isCEOOSOwned == true`.
- `EKEventStoreChanged` notifications trigger a reconciliation pass, not a blind re-import.

### App Intents

See Section 7 for the full catalogue. Architecturally:

- `AppEntity` conformances for `Company`, `Project`, `Person`, `TaskEntity`, `DelegationEntity` with `EntityQuery` + `EntityStringQuery` so Siri can resolve "XPro Health" or "Rafael" by name, including nicknames and short names.
- `IndexedEntity` → automatic Spotlight indexing, so projects and people are findable from Search and via Siri without opening the app.
- `AppShortcutsProvider` supplies fixed invocation phrases (the ones Siri needs to learn without you opening the app).
- Intents execute against `CEOOSKit` services in-process; results return `ProvidesDialog` + `ShowsSnippetView` so Siri can *speak* the answer and show a card.

### Notifications

`UserNotifications`, **local only** in Phase 1–2. No push server, no APNs, no backend.

Everything CEO OS needs to notify about is derived from data already on the device, at a time already known. There is nothing a server would add except cost, latency, and a place for your business data to leak. Push is only introduced if/when Phase 3 collaboration means another human can change your data.

The scheduling model and the interruption budget are in Section 8.

### Google Calendar

- OAuth 2.0 **Authorization Code + PKCE** via `ASWebAuthenticationSession`. No embedded web view, no client secret in the binary.
- Scopes requested at minimum: `calendar.readonly` at connect time; `calendar.events` only escalated when you first ask to create a Google-side event.
- Tokens in Keychain, `ThisDeviceOnly`, never synced.
- Incremental sync with `syncToken`; full resync on `410 GONE`.
- **Read path is conditional** — if a Google calendar is already mirrored into Apple Calendar on your device, CEO OS reads it via EventKit and does *not* call the Google API for it. See Section 6.

### Authentication & security

| Concern | Approach |
|---|---|
| App lock | `LocalAuthentication` (Face ID → passcode fallback), configurable grace period, blur-on-background in the app switcher |
| At rest | iOS Data Protection, `NSFileProtectionComplete` on the store; CloudKit encrypts server-side |
| In transit | TLS via URLSession; ATS enforced; certificate pinning is *not* used (it breaks on Google cert rotation and buys little here) |
| Tokens | Keychain, device-only, never in SwiftData or CloudKit |
| Telemetry | **None.** No analytics SDK, no crash reporter that uploads content, no third-party frameworks with network access |
| Data egress | Zero by default. Only EventKit (on-device), CloudKit (your account), and Google Calendar (your account, opt-in). Any AI beyond on-device is opt-in with an explicit disclosure — see below |

### AI layer

Three tiers, each independently switchable. The default install is Tier 0 + Tier 1, meaning **no data ever leaves the device for AI purposes.**

**Tier 0 — Deterministic (no model).** Powers the dashboard, brief, project health, risk, conflicts, and search. Rule-based and fully explainable. This tier alone delivers roughly 80% of the perceived intelligence, and it is the only tier that is allowed to drive notifications.

**Tier 1 — On-device (Apple Foundation Models).** Used for:
- capture classification and entity extraction beyond what the deterministic parser resolves
- summarising a week of project updates into two sentences
- turning a natural-language search into a structured query

Guarded behind an availability check, with the deterministic parser as the permanent fallback. On-device means no network, works on a plane, and no business data leaves the phone.

**Tier 2 — Cloud (opt-in, Phase 2, off by default).** The conversational Chief of Staff. Architecture that makes hallucination structurally difficult:

1. The model is **never given your database.** It is given a set of typed tools: `findProjects(status:company:staleDays:)`, `findWaitingItems(person:overdueOnly:)`, `findDecisions(pending:)`, `getSchedule(date:)`, `searchRecords(query:types:)`.
2. The tools run locally against SwiftData and return **record IDs plus minimal fields**.
3. The model composes only the *framing sentence*. Every factual claim in the answer is rendered by the app from the returned records, as tappable chips.
4. If the tools return nothing, the answer is *"I don't have anything on that"* — the model is not permitted to fill the gap.
5. Before the first cloud call, a one-time disclosure screen lists exactly which fields can be transmitted, with a per-field opt-out. A "Redact names" mode substitutes stable pseudonyms for Person and Company names before transmission and reverses them on display.

```
You: "What am I forgetting?"
   → AttentionEngine.evaluate()            [Tier 0, local, no model]
   → 6 signals, ranked, each with evidence
   → answer rendered from signals; model only writes the opening line
   → every line taps through to the record it came from
```

---

## SECTION 6 — SYNC STRATEGY & SOURCE OF TRUTH

### The source-of-truth table

| Data | Source of truth | Lives in CloudKit | Mirrored out | Notes |
|---|---|---|---|---|
| Companies, Projects, Milestones, Goals | **CEO OS** | Yes | No | Never leaves CEO OS |
| Tasks | **CEO OS** | Yes | Optionally to Reminders | Per-task opt-in mirror |
| Delegations, Follow-ups, Waiting On | **CEO OS** | Yes | No | No external equivalent exists |
| Ideas, Notes, Decisions, Updates | **CEO OS** | Yes | No | Append-only where narrative |
| People | **CEO OS** (Contacts is a lookup source, not a store) | Yes | No | Optional `contactIdentifier` link only |
| Attention signals, health, risk | **Computed** — no source of truth | Only dedup metadata | No | Recomputed on every device |
| Calendar events (existing) | **EventKit / Google** | Pointer + cache only | No | CEO OS never owns event content |
| Focus blocks & CEO OS-created events | **CEO OS owns the intent; EventKit holds the event** | Link record | Yes, to the CEO OS calendar only | The only events CEO OS may edit |
| Reminders (existing, outside the CEO OS list) | **Apple Reminders** | No | No | Read-only, never imported unless you act |
| Reminders mirroring a CEO OS task | **CEO OS** for content; Reminders for completion | Link record | Yes | See loop-prevention below |
| Google Calendar events | **Google** | Pointer + cache only | No | Read; write only on explicit action |
| OAuth tokens | **Keychain, per device** | **No — explicitly excluded** | No | Never synced |
| Audio capture files | Local + CloudKit as `.externalStorage` | Yes | No | Deleted after transcription confirm |

### CloudKit conflict resolution

SwiftData's CloudKit mirroring is **last-writer-wins at the record level** with no merge hook. You cannot change that. So the design makes LWW safe rather than pretending it can be overridden:

1. **Append-only for anything you typed.** `ProjectUpdate`, `Note` bodies created as separate records, `CaptureItem`, `StatusHistory`, `Decision.rationale` (written once at decision time). A conflict can delete a *checkbox state*; it can never delete a paragraph.
2. **Nothing derived is stored.** Health, overdue, risk, counts. Two devices cannot disagree about something neither one persists.
3. **Fine-grained records.** `ExternalReminderLink` is separate from `Task`, so a background mirror-sync write on device A cannot overwrite the title you are editing on device B.
4. **Completion is monotonic.** `completedAt` is set-once. On conflict, the app treats *any* non-nil `completedAt` as winning over `nil`. Marking done never gets undone by a stale device. This is applied as a post-merge repair pass on load, since CloudKit itself cannot enforce it.
5. **Destructive operations are soft.** Deletes set `archivedAt` rather than removing the record; a hard purge happens locally after 30 days. A sync race can never permanently destroy a project.
6. **Offline-first.** All writes are local and immediate. The sync indicator shows pending-change count and last-successful-sync; it never blocks the UI.

### Apple Reminders — the anti-duplication contract

This is where most integrations of this kind break, so the rules are absolute:

**Rule 1 — Mirroring is opt-in per task.** Creating a task in CEO OS does not create a reminder. You toggle "Also in Reminders" on a task, or set a default per project. Most tasks never touch Reminders.

**Rule 2 — Import is confined to one list.** CEO OS reads reminders for display, but **only auto-imports from a single designated list** ("CEO OS Inbox"). A reminder created anywhere else in your Reminders app never spontaneously becomes a CEO OS task. You can import one manually; that is a deliberate act.

**Rule 3 — Every mirrored pair has exactly one link record.** `ExternalReminderLink` stores `reminderIdentifier` and `lastPushedFingerprint`. Nothing is created without first checking the registry.

**Rule 4 — Writes are fingerprint-gated.** Before pushing, CEO OS computes `hash(title, dueDate, notes, priority)`. If it equals `lastPushedFingerprint`, the write is skipped. This is what breaks the echo loop: our own write comes back as an `EKEventStoreChanged` event, the fingerprint matches, and the change is ignored.

**Rule 5 — Direction is asymmetric by field.**

| Field | CEO OS → Reminders | Reminders → CEO OS |
|---|---|---|
| Title, notes, priority | Yes (authoritative) | No |
| Due date, alarms, recurrence | Yes (authoritative) | Yes — accepted, because rescheduling from the Reminders app is a legitimate workflow |
| Completion | Yes | Yes — completion always wins in both directions |
| Deletion | Yes | **No** — a deleted reminder marks the link `detached` and raises an in-app prompt. It never silently deletes your CEO OS task |

**Rule 6 — Reconciliation is a diff, never a re-create.** On `EKEventStoreChanged`, the sync pass walks the link registry, compares, and applies deltas. It never enumerates CEO OS tasks and pushes them wholesale.

**Rule 7 — Detached links surface, they don't self-heal.** If the reminder is gone or the identifier is stale, the link goes to `detached` and shows a one-tap "Recreate" or "Unlink" in the task detail. Automatic re-creation is exactly how you end up with fourteen copies of the same reminder.

### Apple Calendar

- CEO OS is a **reader** of your calendars. It stores `CalendarEventLink` (identifier + cached fields for offline display), never the event itself.
- CEO OS writes only to its own "CEO OS" calendar, created on first focus block with your confirmation.
- Editing or deleting an event CEO OS did not create is blocked at the service layer, not just hidden in the UI.
- Meeting↔project linking is a suggestion, never an edit to the event. The link is stored on the CEO OS side. Your calendar is never annotated.

### Google Calendar — deduplication

The critical question: **is this Google calendar already flowing into Apple Calendar on this device?** If yes, calling the Google API for it creates a second copy of every event.

**Detection, at connect time and on every sync:**

1. Enumerate `EKSource`s. Any source of type `.calDAV`/`.exchange`/`.subscribed` whose title or account matches a connected Google account is a *mirror source*.
2. For each Google calendar you select, look for an EventKit calendar in a mirror source whose title matches, or that contains events whose `calendarItemExternalIdentifier` matches the Google `iCalUID` for a sample window.
3. Classify each Google calendar as **`mirroredInEventKit`** or **`directOnly`**.
4. **Mirrored calendars are read exclusively through EventKit.** The Google API is used for them only to write, and only when you explicitly create/edit a Google-side event.
5. `directOnly` calendars are fetched via the API and merged into the schedule view, tagged with their source.

**The dedup key, in priority order:**

| Priority | Key | Why |
|---|---|---|
| 1 | `iCalUID` (Google) ⇄ `calendarItemExternalIdentifier` (EventKit) | Google's iCalUID survives the CalDAV mirror. This resolves the large majority of cases exactly. |
| 2 | `iCalUID` + `originalStartTime` | Required for recurring series — every instance shares a UID, so the occurrence start disambiguates |
| 3 | Fuzzy fingerprint: `normalizedTitle` + `startInstant` + `durationMinutes` + `organizerEmail` | Fallback for events whose UID was rewritten in transit (some Exchange/relay paths do this) |

Fuzzy matches are **collapsed in the UI but flagged internally**, and Diagnostics lists them, so a bad heuristic is visible rather than silently hiding a real event. Two events that are genuinely distinct but look identical is a far worse failure than showing a duplicate once.

**Write policy:** Google-side writes require explicit action. CEO OS never mirrors its tasks or focus blocks into Google automatically. Focus blocks go to the Apple "CEO OS" calendar; if that account is itself Google-backed, they appear in Google naturally, with no second write path.

---

## SECTION 7 — SIRI / APP INTENTS ARCHITECTURE

### The key design decision

Siri is unreliable at slot-filling six parameters from one spoken sentence. So the architecture uses **one freeform workhorse intent plus a set of precise typed intents**:

- **`QuickCaptureIntent(text: String)`** takes the whole sentence as one string and runs it through the same `CaptureParser` the app uses. This handles the messy, natural, multi-clause sentences — *"Follow up with Rafael about the XPro Health lease next Wednesday."* One parameter means Siri almost never fails to invoke it.
- **Typed intents** (`CreateTaskIntent`, `CreateDelegationIntent`, …) exist for Shortcuts, automations, widgets, and when you want precision. They are what a Shortcut or a Focus automation calls.

Both paths call the same `CEOOSKit` services. There is no separate Siri code path to keep in sync.

### Intent catalogue

#### Capture (write)

| Intent | Parameters | Example phrases |
|---|---|---|
| `QuickCaptureIntent` | `text` | "Add to CEO OS: follow up with Rafael about the XPro Health lease next Wednesday" · "Brain dump in CEO OS: I think we should create an executive health membership" |
| `CaptureTaskIntent` | `title`, `project?`, `company?`, `dueDate?`, `priority?` | "Add a task to CEO OS to review the XPro Health numbers tomorrow morning" |
| `CaptureIdeaIntent` | `text`, `company?`, `project?` | "Add an idea to CEO OS for XPro Vault: create a premium metal membership card" |
| `CaptureNoteIntent` | `text`, `company?`, `project?`, `person?` | "Note in CEO OS: Aaron mentioned the Vegas venue is holding until the 15th" |
| `CreateFollowUpIntent` | `subject`, `person`, `dueDate?` | "Follow up with Aaron on Friday in CEO OS" |
| `CreateDelegatedItemIntent` | `what`, `person`, `dueDate?`, `followUpDate?` | "Have Rafael send me the lease numbers Friday" |
| `AddProjectUpdateIntent` | `project`, `body`, `percentComplete?` | "Add an update to XPro Health Website in CEO OS" |
| `LogDecisionIntent` | `title`, `company?`, `rationale?` | "Log a decision in CEO OS" |

#### Action (write)

| Intent | Parameters | Example phrases |
|---|---|---|
| `CompleteTaskIntent` | `task` (`EntityQuery`, disambiguates by title) | "Mark the Aaron follow-up complete in CEO OS" |
| `CompleteDelegationIntent` | `delegation` | "Rafael's lease numbers are done" |
| `CreateFocusBlockIntent` | `date`, `startTime`, `duration`, `linkedPriority?` | "Create a focus block in CEO OS tomorrow from 9 to 11" |
| `SnoozeSignalIntent` | `signal`, `until` | Shortcuts / notification action |
| `SetTopThreeIntent` | `items` | Morning routine Shortcut |

#### Query (read — `ProvidesDialog` + `ShowsSnippetView`)

| Intent | Spoken answer | Example phrases |
|---|---|---|
| `ShowTodaysPrioritiesIntent` | Reads the Top 3 | "What are my priorities today?" |
| `ShowTodaysScheduleIntent` | Meeting count, next meeting, first free block | "What's my schedule today?" |
| `ShowWaitingItemsIntent` | "You're waiting on 4 things. 2 are overdue: Rafael, lease numbers…" | "What am I waiting on?" · "Who owes me what?" |
| `ShowProjectsAtRiskIntent` | Project + the reason | "What projects are behind?" |
| `ShowAttentionIntent` | Top signals | "What needs my attention?" |
| `FindProjectIntent` | Status, next action, blocker, last update | "What's happening with XPro Health?" |
| `ShowPersonItemsIntent` | What you delegated + follow-ups | "What is Rafael working on?" |
| `ShowDecisionsRequiredIntent` | Pending decisions with age | "What needs my approval?" |

#### Contextual

`AddToCompanyIntent(company:, text:)` — *"Add this to Kamboj Ventures"* — pins the target company and routes the text through the parser with the company pre-resolved.

### Entity resolution

`AppEntity` + `EntityStringQuery` for Company, Project, Person, Task, Delegation. Each carries a **synonyms array** so "XPro" resolves to the right company and "Raf" to Rafael. Ambiguity produces a Siri disambiguation prompt rather than a guess.

`IndexedEntity` conformance puts projects, people, and companies in Spotlight, which also improves Siri's on-device matching.

### Confirmation policy

- **Write intents that create** → no confirmation. Speed matters more; capture is always reversible from the Inbox.
- **Write intents that complete or modify** → spoken confirmation (`requestConfirmation`) naming the exact record: *"Mark 'Follow up with Aaron' complete?"*
- **Anything writing to Calendar or Reminders** → always confirmed. Never silently modify external data.

### Shortcuts and Focus

Every intent is exposed to Shortcuts. Recommended automations to ship as pre-built shortcuts: *Morning Brief* (7:00), *Shutdown Review* (18:00), *Meeting Debrief* (on calendar-event-end), *Deep Work* (Focus mode → creates a focus block and mutes non-critical CEO OS notifications).

---

## SECTION 8 — NOTIFICATION LOGIC

### The principle

**A notification is a debt you take from your own attention.** CEO OS assumes a hard daily budget and spends it deliberately. The default is **two scheduled notifications plus at most four event-driven ones per day.** Everything else is aggregated into the Morning Brief or shown in-app.

### The gate

Every candidate notification passes five checks in order. Failing any one means it does not fire; it appears in-app and in the next brief instead.

```
1. ACTIONABLE NOW?        Can you do something about it in the next few hours?
                          "Project at risk" at 11pm fails. "Meeting in 15 min" passes.
2. ALREADY KNOWN?         Same signalKey notified within cooldown (default 24h)?
                          Suppress — UNLESS severity increased since last notification.
3. WITHIN BUDGET?         Event-driven count for today < dailyNotificationBudget?
                          Over budget → the highest-severity pending item batches into
                          a single "3 items need attention" summary.
4. QUIET HOURS / FOCUS?   Outside workday, or a Focus mode is suppressing?
                          Defer to the next window boundary. Never drop silently.
5. STILL TRUE?            Re-evaluated at delivery time, not schedule time.
                          A delegated item completed after the notification was
                          scheduled must not fire. Enforced with a
                          UNNotificationServiceExtension-style pre-delivery check on
                          app foreground plus aggressive cancel-on-change.
```

### What CEO OS notifies about

| Kind | When | Default level |
|---|---|---|
| **Morning Brief** | `briefTime`, weekdays | Immediate — the one guaranteed daily interruption |
| **Shutdown Review** | `shutdownTime`, weekdays | Immediate |
| **Weekly Review** | Configured weekday/time | Immediate |
| **Meeting prep** | 30 min before a meeting linked to a project, only if prep is empty | Immediate |
| **Delegated item overdue** | Morning after the due date passes | Immediate, max 1/day aggregated |
| **Follow-up due** | Morning of the follow-up date | Digest → folded into the brief |
| **Decision required** | Pending decision hits `neededBy − 2 days`, or 7 days old | Immediate |
| **Deadline approaching** | Project target date in 3 days with < 60% complete | Immediate |
| **Project at risk** | A project *newly* enters At Risk | Immediate, once per transition |
| **Calendar conflict** | New double-booking detected in the next 48h | Immediate |
| **Focus block starting** | 5 min before | Digest, off by default |

### What CEO OS never notifies about

- A task simply being created, edited, or synced
- Sync completion, CloudKit status, or anything about the app's own machinery
- A project *staying* at risk (only the transition into it)
- Low-priority tasks becoming overdue — these accumulate into the brief
- Anything at all between `shutdownTime` and `briefTime`, except a meeting starting
- Anything that repeats an unchanged signal you have already seen

### Scheduling mechanics

- **iOS allows only 64 pending local notifications.** CEO OS schedules a **rolling 72-hour window**, refreshed on foreground, after any relevant edit, and on `BGAppRefreshTask`. Beyond that window, scheduling is recomputed rather than pre-booked.
- **Background execution is not guaranteed.** Therefore no state may depend on a background pass having run. Every time-based signal is computed on demand at read. `BGAppRefreshTask` is an *optimisation* for notification freshness, never a correctness requirement.
- **Cancel aggressively.** Completing a delegation immediately cancels its pending overdue notification on that device; other devices reconcile on next foreground. A notification for something already done is the fastest way to lose trust in the system.
- Notification identifiers are the `signalKey`, so re-scheduling naturally replaces rather than duplicates.
- Rich actions on the notification itself: *Complete · Snooze 1 day · Nudge* (opens a pre-filled message to the delegate) — resolving without opening the app.

### Levels

Per `NotificationRule` kind: **Off · Digest only · Immediate**, plus a global "Quiet week" switch that suspends everything except the morning brief and meeting prep.

---

## SECTION 9 — MVP BUILD ORDER

Your proposed roadmap is close. I am changing it in six places, and the reasons are dependency-ordering, not preference.

### Changes from your list, and why

| Change | Reason |
|---|---|
| **New Phase 0** (project foundations) before anything | App Group container, CloudKit container, versioned schema, and the deep-link router are all near-impossible to retrofit onto a live synced database. This is the "no placeholder architecture" rule applied literally. |
| **People before Delegation** | Delegation and Follow-up both require a Person. Building delegation on free-text names guarantees a data migration. |
| **Attention Engine before the Dashboard** | The dashboard, notifications, brief, widget, and AI all render the same signals. Building the dashboard first means writing that logic in a view and then extracting it — twice. |
| **Calendar read before Reminders write** | Reading is low-risk and the dashboard needs Today. Reminders is the first two-way sync and should be built after the `ExternalLink` pattern is proven by the simpler calendar case. |
| **Widgets moved into Phase 1** | Once the App Group and Attention Engine exist, the widget is roughly a day of work and is one of the highest-value surfaces for your actual problem (not opening the app and still knowing). Deferring it to Phase 2 is leaving value on the table. |
| **Google Calendar stays in Phase 2, and may not be needed at all** | If your Google calendars already sync into Apple Calendar (very likely, given a Workspace account on an iPhone), EventKit already gives you read access. Direct API integration then only buys Google-side writes. See Question 2. |

### Phase 0 — Foundations *(do not skip; ~1 week)*

| # | Step | Definition of done |
|---|---|---|
| 0.1 | Xcode project, targets, App Group, CloudKit container, entitlements, bundle IDs | A widget target can read the SwiftData store |
| 0.2 | Schema v1 + `VersionedSchema` + `SchemaMigrationPlan` + CloudKit-compatibility unit test | Test fails the build on a non-optional or unique attribute |
| 0.3 | Design system: tokens, type ramp, spacing, core components, dark mode | A style gallery screen renders every component in both appearances |
| 0.4 | App shell, 5 tabs, typed `Codable` navigation path, `DeepLinkRouter` | `ceoos://project/<uuid>` opens the right screen from cold launch |
| 0.5 | State infrastructure: `PermissionGate`, `EmptyState`, `ErrorState`, offline banner, sync status | Every permission can be denied and the app still works |
| 0.6 | App lock (Face ID + grace period + switcher blur) | Locks and unlocks reliably; never locks you out |

### Phase 1 — MVP *(the reliable core)*

| # | Feature | Notes |
|---|---|---|
| 1 | **Companies** | CRUD, colour, symbol, archive. Seeded from your list but fully editable. |
| 2 | **People** | CRUD + optional Contacts lookup + synonyms for Siri |
| 3 | **Projects, Milestones, Project Updates** | Full field set; updates append-only |
| 4 | **Tasks** | Full field set + all views |
| 5 | **Ideas, Notes, Decisions** | Lightweight storage + lists. Needed now because Capture targets them. |
| 6 | **Delegations, Follow-ups, Waiting On** | The delegation lifecycle and the "who owes me what" screen |
| 7 | **Attention Engine** | Rules R1–R14 (Appendix A), signal persistence, snooze, explanations |
| 8 | **CEO Dashboard** | Renders the engine. First time the product feels real. |
| 9 | **Universal Capture** | Deterministic parser only (no model yet), confirmation sheet, Inbox |
| 10 | **Global Search** | All entity types, grouped results |
| 11 | **Apple Calendar (read)** | Today, schedule, conflict detection, meeting↔project linking |
| 12 | **Focus blocks (write)** | First EventKit write. CEO OS-owned calendar only. |
| 13 | **Apple Reminders mirror** | The full anti-duplication contract from Section 6 |
| 14 | **App Intents / Siri** | `QuickCaptureIntent` first, then the typed and query intents |
| 15 | **Notifications** | The gate, the budget, rolling-window scheduling |
| 16 | **Morning Brief + End of Day Review** | The two rituals that make the system stick |
| 17 | **Widgets** | Home Screen (Top 3 + next meeting + top signal + capture) and Lock Screen |

**Ship Phase 1 and live on it for two weeks before starting Phase 2.** The single biggest risk to this product is building Phase 2 features on top of a Phase 1 you have not actually used.

### Phase 2 — Intelligence & breadth

18. Meetings: prep cards and the debrief flow
19. Weekly CEO Review (guided)
20. On-device AI classification (Tier 1) layered onto the existing parser
21. Google Calendar (only if Question 2 says it is needed)
22. AI Chief of Staff (Tier 2, opt-in, tool-calling with citations)
23. Advanced risk rules + trend view ("what changed this week")
24. Goals
25. iPad and Mac layouts (mostly navigation and multi-column work, since the domain layer is shared)

### Phase 3 — Extension

26. Apple Watch: capture + Top 3 + complication (query/capture only, not full sync)
27. Focus-mode integration
28. Email integration (read-only capture from a forwarding address)
29. Attachments and richer notes
30. Collaboration and role permissions — **a re-architecture, not a feature.** See Risks.

---

## SECTION 10 — RISKS

Ordered by how likely they are to actually hurt you.

### R1 — CloudKit last-writer-wins can lose edits *(high likelihood, medium impact)*

SwiftData's CloudKit mirroring offers no merge hook. Editing the same project's `notes` on your iPhone and Mac within a sync window loses one version silently.
**Mitigation:** the append-only design in Section 6 (updates, notes, captures, decisions are separate records), no derived state stored, monotonic completion, soft deletes. **Residual risk:** long free-text fields that *are* editable (`Project.notes`, `blockerText`) can still lose an edit. Accepted, because they are short and low-stakes; the diagnostics screen shows recent sync activity if something looks wrong.

### R2 — Duplicate calendar events *(high likelihood without the design in Section 6)*

Google → Apple mirroring plus a direct Google API read gives every event twice. Recurring events make it worse, since instances share an `iCalUID`.
**Mitigation:** mirror detection at connect time, `iCalUID` as primary dedup key, `iCalUID + occurrenceStart` for recurrences, fuzzy fallback that is *flagged rather than silent*, and a Diagnostics list of every collapsed pair.

### R3 — Reminder duplication loops *(high likelihood without the contract)*

CEO OS writes a reminder → EventKit fires a change notification → the app reads it as new → creates another task → pushes another reminder.
**Mitigation:** fingerprint gating (Rule 4), one-list import confinement (Rule 2), a single link registry (Rule 3), diff-based reconciliation (Rule 6), and no automatic re-creation of detached links (Rule 7).

### R4 — Background execution is not guaranteed *(certain)*

`BGAppRefreshTask` runs when iOS feels like it. If notification scheduling depends on it, notifications will be missed.
**Mitigation:** rolling 72-hour pre-scheduled window; all state computed on demand; background refresh treated purely as an optimisation. Also the 64-pending-notification cap forces the rolling window anyway.

### R5 — Google OAuth in "Testing" mode expires refresh tokens after 7 days *(certain if misconfigured)*

An unverified external OAuth consent screen in testing status invalidates refresh tokens weekly. You would be re-authenticating every Monday forever.
**Mitigation:** because you have a Google Workspace domain (`kambojventures.com`), create the OAuth client in a Workspace-owned Cloud project with **user type = Internal**. Internal apps skip verification entirely and do not expire refresh tokens. This is the single most important configuration detail of the Google integration.

### R6 — EventKit permission granularity *(medium)*

iOS 17+ separates write-only from full calendar access, and Reminders requires full access to read. If you tap the wrong prompt once, features silently do nothing.
**Mitigation:** explicit `PermissionGate` states that name the missing permission, explain what it unlocks, and deep-link to Settings. Never a blank screen.

### R7 — App Intents / Siri fragility *(medium likelihood, low impact)*

Siri's phrase matching is inconsistent, especially with many parameters, and it changes between OS versions.
**Mitigation:** the single-parameter `QuickCaptureIntent` as the primary path; every intent also reachable from Shortcuts, the widget, and the Lock Screen so no capture route depends solely on Siri.

### R8 — Speech transcription errors corrupting records *(medium)*

Dictated "XPro Vault" becomes "expo vault"; the parser then creates a new company.
**Mitigation:** the parser only ever *matches* against existing companies/projects/people with a fuzzy threshold; **it never creates a Company or Person implicitly.** Unmatched entities become plain text plus an Inbox item.

### R9 — Notification fatigue *(medium likelihood, high impact — it kills the product)*

If CEO OS becomes noisy you will mute it, and then it stops working entirely.
**Mitigation:** the five-check gate, the hard daily budget, transition-only alerts, and conservative defaults. **Ship with fewer notifications than feel right and add on request.**

### R10 — AI hallucination destroying trust *(medium likelihood, high impact)*

One confident wrong answer about a delegation and you will never trust the AI layer again.
**Mitigation:** Tier 0 answers everything it can without a model; Tier 2 renders facts from returned records with citations, and the model writes only framing. Explicit "I don't have anything on that." AI never drives notifications and never makes a high-impact change without confirmation.

### R11 — Data egress *(low likelihood, very high impact)*

This database contains acquisition discussions, financials, and personnel matters across nine companies.
**Mitigation:** zero third-party SDKs, no analytics, no crash-content upload, tokens device-only in Keychain, Tier 0/1 fully on-device, Tier 2 off by default behind an explicit per-field disclosure and an optional name-redaction mode.

### R12 — Collaboration in Phase 3 is a re-architecture *(certain, if pursued)*

SwiftData + CloudKit private database has no multi-user story. Sharing means CloudKit shared zones (limited SwiftData support, significant model changes) or a real backend — plus a permissions model, an invitation flow, and server-side notifications.
**Mitigation:** do not design Phase 1 around a hypothetical Phase 3. Keep the domain layer in `CEOOSKit` with no CloudKit assumptions leaking into it, so the persistence layer can be swapped for shared entities without touching business logic. Budget collaboration as a major project, not an increment.

### R13 — Schema churn during Phase 1 *(high likelihood, medium impact)*

You will want to change the model as you use it, and by then there is real data in CloudKit. CloudKit schema changes are additive-only in production; you cannot delete or retype a field.
**Mitigation:** stay in the CloudKit **development** environment until Phase 1 is complete and the schema has stabilised, then promote to production once. Versioned schema from v1. Be deliberately generous with fields in v1 — an unused optional field is cheap; a missing one is a migration.

### R14 — Scope creep *(high likelihood, high impact)*

The spec describes roughly three years of a small team's work. The realistic failure mode is a half-finished Phase 2 sitting on an unpolished Phase 1.
**Mitigation:** the phase gate above. Phase 1 must be lived in for two weeks before Phase 2 begins.

### R15 — Distribution and signing *(low impact, but it will bite on day one)*

A free Apple developer account re-signs apps every 7 days and does not support App Groups, CloudKit, push, or widgets reliably.
**Mitigation:** a paid Apple Developer Program membership is a hard prerequisite. TestFlight is the right distribution channel for a private app on your own devices.

### R16 — Apple Watch expectations *(low)*

SwiftData + CloudKit on watchOS is slow and battery-hungry for a database this size.
**Mitigation:** the Watch app is capture + a small read-only summary delivered via `WidgetKit`/complications and App Intents, not a full mirror of the database.

---

## SECTION 11 — QUESTIONS I ACTUALLY NEED ANSWERED

Everything else in this document I have decided on your behalf. These eight genuinely change the architecture.

**1. Minimum OS version — iOS 26+, or iOS 18+?**
*Recommendation: iOS 26+.* You are the only user. Targeting the current OS unlocks the on-device Foundation Models framework (private AI classification with zero data egress), the newest App Intents capabilities, and lets me skip several compatibility branches. The only cost is that every device you use must be current.

**2. Are your Google calendars already synced into Apple Calendar on your iPhone?**
This determines whether the Google Calendar integration is needed at all. If your Workspace account is added in iOS Settings → Calendar, EventKit already reads those events, and direct API integration only adds Google-side *writes* — which may not be worth the complexity, the OAuth surface, or the duplication risk.

**3. Google Cloud project — is `kambojventures.com` a Google Workspace domain you control the admin console for?**
If yes, the OAuth client should be **Internal** user type, which avoids app verification and the 7-day refresh-token expiry (Risk R5). If no, we need a different token-refresh strategy.

**4. Cloud AI: on-device only, or is a redacted cloud tier acceptable?**
On-device only means the Chief of Staff is more literal and less conversational, but nothing ever leaves your phone. If a cloud tier is acceptable, I need to know whether name redaction (real names replaced with stable pseudonyms in transit) should be the default.

**5. Will anyone other than you ever need access?**
Not "would it be nice" — will an assistant, a partner, or a project owner need to write into CEO OS? If the honest answer is yes within a year, we should keep an escape hatch in the persistence layer now. If it is no, the private-CloudKit design is materially simpler and I will commit to it.

**6. Apple Reminders: which direction do you actually want?**
Options: (a) **CEO OS → Reminders only** — mirror selected tasks out, accept completion back. Simplest, safest. (b) **Two-way with a dedicated inbox list** — you can also add via the Reminders app and it flows in. (c) **No Reminders integration** — CEO OS is the only task system.
*Recommendation: (b)*, because Siri-to-Reminders is a habit you already have and it gives a capture path that works even if CEO OS is broken.

**7. Top 3 — who picks them?**
(a) You choose each morning from a proposed list *(recommended)*, (b) the system picks and you can override, or (c) you set them manually with no proposal. This changes how much the Attention Engine's ranking has to be trusted.

**8. Delegation nudges — should CEO OS help you chase people?**
When a delegated item is overdue, should the notification offer a **Nudge** action that opens a pre-filled iMessage/email to that person? It is the highest-leverage feature in the delegation system, but it means CEO OS composes outbound messages on your behalf (you still send them). Yes or no.

---

## APPENDIX A — ATTENTION ENGINE RULES

Every rule is deterministic, produces a human-readable explanation, and cites the records that triggered it. **There is no scoring model.** Severity is `info < notice < warning < critical`.

| ID | Rule | Condition | Severity | Explanation template |
|---|---|---|---|---|
| R1 | Stale project | Active project, no `ProjectUpdate` in ≥7 days | notice (≥7d) → warning (≥14d) | "No update in {n} days" |
| R2 | Milestone overdue | Milestone `dueDate < today`, not completed | warning (1–3d) → critical (≥4d) | "{milestone} is {n} days overdue" |
| R3 | Deadline approaching | `targetDate` ≤7d and `percentComplete` <80 | notice → warning (≤3d and <60%) | "Due in {n} days at {p}% complete" |
| R4 | Blocked | `status == blocked`, or `blockerText` set for >3 days | warning → critical (>7d) | "Blocked for {n} days: {blocker}" |
| R5 | Progress/timeline mismatch | `elapsedFraction − percentComplete/100 > 0.25` | notice → warning (>0.40) | "{e}% of the timeline used, {p}% complete" |
| R6 | Owner has overdue deliverable | Project owner has an overdue Task or Delegation on this project | notice | "{owner} has {n} overdue items on this project" |
| R7 | Delegation overdue | `dueDate < now`, not completed/cancelled | warning → critical (≥3d) | "{person} — {what}, {n} days late" |
| R8 | Follow-up due | `followUp.dueDate ≤ today`, open | notice | "Follow up with {person} about {subject}" |
| R9 | Decision required | Pending decision, `neededBy ≤ +3d` **or** age >7d | warning → critical (past `neededBy`) | "Pending {n} days: {title}" |
| R10 | Calendar conflict | Two accepted, non-all-day events overlap >5 min in the next 48h | warning | "{a} overlaps {b} by {n} minutes" |
| R11 | Meeting prep needed | Linked meeting within 24h, `prepNotes` empty | notice | "{meeting} tomorrow with no prep notes" |
| R12 | Important task overdue | Task priority ≥ high, overdue | notice → warning (≥3d) | "{title}, {n} days overdue" |
| R13 | Unprocessed capture | `CaptureItem` unprocessed >24h | info | "{n} captures still unfiled" |
| R14 | Structural gap *(weekly review)* | Active project missing owner, `targetDate`, or `nextActionText` | notice | "{project} has no {field}" |

**Project health** is the worst severity among R1–R6 active on that project:
`critical → At Risk` · `warning → Needs Attention` · `blocked status → Blocked` · `none → On Track` · `completedAt set → Completed`

A `healthOverride` supersedes this but **always expires** (default 14 days), so a stale override cannot permanently hide a problem.

**Composite explanations** join the top two contributing rules:
> *"XPro Health Website is At Risk because Milestone 3 is 4 days overdue and there has been no project update in 8 days."*

Every signal carries `evidenceUUIDs`, so every line in the dashboard, brief, and AI answer taps straight through to the underlying records.

---

## APPENDIX B — CAPTURE PARSER (deterministic, Phase 1)

Runs entirely on-device with no model. This is what makes capture reliable before any AI exists.

```
Input: "Follow up with Rafael about the XPro Health lease next Wednesday"

1. TYPE       Leading-phrase match against ordered patterns:
              "follow up with|circle back"  → FollowUp
              "have|ask|get {person} to"    → Delegation
              "idea:|idea for"              → Idea
              "note:|remember that"         → Note
              "decided|we're going with"    → Decision
              "brain dump:"                 → Note (unclassified)
              default                       → Task
              → FollowUp

2. DATE       NSDataDetector + a relative-date grammar
              ("next Wednesday", "Friday", "tomorrow morning" → 09:00,
               "end of week" → Friday 17:00)
              → 2026-09-02

3. PERSON     Fuzzy match against People (Levenshtein ≤2 + synonyms).
              NEVER creates a Person.
              → Rafael  (confidence 0.95)

4. COMPANY    Fuzzy match against Companies + shortNames + synonyms.
              NEVER creates a Company.
              → XPro Health  (confidence 0.98)

5. PROJECT    Match against active projects, weighted toward the matched
              company; token overlap on "lease".
              → no confident match → left unset

6. SUBJECT    Remaining text after removing matched spans.
              → "the XPro Health lease"

Confidence = min(component confidences).
  ≥ 0.85 → save + toast, auto-dismiss in 3s
  0.5–0.85 → save + confirmation sheet with the guesses pre-filled
  < 0.5 → save raw to Inbox, ask nothing
```

**The rule that matters: the raw `CaptureItem` is written to disk before parsing starts.** If parsing crashes, the network is down, or classification is wrong, the words you said are never lost. Everything after step 0 is an enhancement.

Tier 1 (on-device Foundation Models) later runs *after* this parser and only fills gaps the deterministic path left empty. It never overrides a high-confidence deterministic match.

---

## FINAL PRINCIPLE

CEO OS succeeds when you stop keeping a mental list. That requires two properties, in this order:

1. **You trust that capture never loses anything.** Achieved by writing raw input to disk first, always, before any parsing, network call, or classification.
2. **You trust that it brings things back at the right time.** Achieved by one deterministic, explainable Attention Engine driving every surface, and a notification budget that keeps the signal worth reading.

Every feature in this document either serves one of those two properties or it should be cut.
