# Phase 0 — Setup and first build

Everything in this repository is source. The Xcode project is **generated**, so
there is a short setup the first time.

I have no Swift toolchain or Xcode in the environment I work in, which means
**this code has been written but never compiled.** Expect a round of build
errors on the first attempt, mostly of the "this initialiser has a different
label in this SDK" kind. Paste them to me and I will fix them — that is the
expected workflow for this slice, not a sign something is wrong.

---

## 1. Prerequisites

- **Xcode 26** or later (the project targets iOS 26).
- A **paid Apple Developer Program** membership. This is not optional: a free
  account cannot use App Groups, CloudKit, background push, or widgets — which
  is most of Phase 0.
- **XcodeGen**: `brew install xcodegen`

> **Why XcodeGen?** A hand-maintained `project.pbxproj` is unreadable, hostile to
> version control, and hides exactly the settings that matter here — the App
> Group, the CloudKit container, entitlements, background modes. `project.yml`
> is 90 reviewable lines instead. It is a build-time tool; nothing from it ships
> inside the app. If you ever want it gone, generate the project once, commit
> the `.xcodeproj`, and delete the tool.

## 2. Signing

```bash
cp Config/Local.xcconfig.template Config/Local.xcconfig
```

Put your Apple Developer Team ID in it. The file is gitignored, so signing
identity never leaves your machine.

## 3. Generate and open

```bash
xcodegen generate
open CEOOS.xcodeproj
```

## 4. Capabilities to confirm in Xcode

The entitlements files already declare everything, but the identifiers must
exist in your developer account. In **Signing & Capabilities**, for both the
`CEOOS` and `CEOOSWidgets` targets, confirm:

| Capability | Value |
|---|---|
| App Groups | `group.com.kambojventures.ceoos` |
| iCloud → CloudKit | `iCloud.com.kambojventures.ceoos` |
| Background Modes (app only) | Remote notifications, Background fetch, Background processing |

Xcode will offer to register anything missing. If you want a different bundle
prefix, change it in exactly four places: `project.yml`,
`Sources/CEOOSKit/Support/AppEnvironment.swift`, and the two `.entitlements`
files.

## 5. Run the tests first

`⌘U`. The tests need no device, no iCloud account, and no entitlements — they
build the whole schema in memory.

`testInMemoryContainerBuilds` is the one that matters. It constructs a container
from every model, which validates the entire object graph: every relationship
resolves, every inverse pairs up, no two properties collide. Almost any mistake
in the model surfaces there rather than on a device at 11pm.

Three further tests enforce the CloudKit rules that otherwise fail silently at
runtime: every attribute optional or defaulted, no unique constraints, every
relationship has an inverse.

## 6. Run the app

The app opens onto **Diagnostics** — deliberately. Until the data layer is
proven on real hardware, that is the only screen worth looking at, and it is a
permanent screen (later: Settings → Diagnostics), not a placeholder. The five-tab
shell arrives in the next slice.

Check, in order:

1. **Mode** reads `iCloud sync on`. If it says *On this device only*, the
   Problems section says why in plain words. The app is fully usable either way.
2. **Shared with widget** reads `Yes`. If not, the App Group is not attached and
   the widget will read an empty database.
3. **Companies** shows nine seeded companies. These are ordinary editable
   records — rename, archive, add. Nothing in the code refers to a company by
   name.
4. Add the widget to your Home Screen. It should show the same company count.
   That is the App Group working end to end.
5. Tap **Add a round-trip test project**, then open the app on a second device
   signed into the same iCloud account. It should appear within a minute or so.
   That is CloudKit mirroring working end to end. Delete them afterwards.

## 7. Keep CloudKit in Development until the schema settles

CEO OS runs against the CloudKit **development** environment while the schema is
still moving, and is promoted to production once, at the end of Phase 1.

This matters more than it sounds. A CloudKit production schema can only be
*added to* — you cannot delete a field, rename one, or change its type, ever.
Promoting early means living with every early mistake permanently. Risk R13.

---

## What this slice contains

| Area | What is here |
|---|---|
| Project | `project.yml`, xcconfig, entitlements, Info.plists for four targets |
| Schema v1 | 24 models, versioned, CloudKit-shaped from the first commit |
| Persistence | Container factory with three-level degradation, migration plan, first-run seeder |
| App | Entry point, root, Diagnostics screen |
| Widget | Minimal, and its only job is to prove the App Group works |
| Tests | Schema compatibility, model behaviour, seeder |

## What it deliberately does not contain

No navigation shell, no design system, no repositories, no `@ModelActor`. Those
arrive in the slices that need them. An abstraction with no callers is the
placeholder architecture that rule 15 rules out — a repository protocol is worth
writing the moment there is a service to put behind it, and not before.

## Design decisions worth knowing before you read the code

**Derived state is never stored.** Project health, "overdue", risk — all
computed on read. Two devices cannot disagree about something neither persists.
This is the main reason CloudKit's last-writer-wins is survivable here.
`DelegationStatus` has no `.overdue` case on purpose.

**Anything narrative is append-only.** `ProjectUpdate`, `CaptureItem`,
`StatusHistory`. A sync conflict can lose a checkbox; it must never lose a
paragraph you wrote.

**Enums are stored as raw strings** with computed accessors. `#Predicate` can
only reference stored properties, so queries filter on `statusRaw`. An unknown
value from a newer build degrades to a default instead of crashing — there is a
test for that.

**Small string lists are delimited, not arrays.** SwiftData stores a primitive
array as an opaque blob that `#Predicate` cannot see inside. `DelimitedList`
encodes tags as `␟ops␟finance␟` so whole-token matching works in a query and
`ops` never matches `operations`.

**Nothing calls `fatalError`.** An app that crashes on launch because iCloud is
signed out cannot tell you that iCloud is signed out.

## Next slice

Design system and the five-tab shell with the deep-link router — `ceoos://project/<uuid>`
resolving from a cold launch, which every notification, widget tap, Spotlight
result, and Siri response will depend on.
