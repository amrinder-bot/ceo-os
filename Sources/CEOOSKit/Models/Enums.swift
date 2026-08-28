import Foundation

// Every enum is stored as its `String` raw value, never as a Swift enum.
//
// Two reasons. CloudKit needs a primitive; and `#Predicate` can only reference
// stored properties, so all filtering happens on the `...Raw` string. Each model
// exposes a computed accessor that reads and writes the raw value, and query
// code uses the raw string directly. Adding a case later is then additive and
// safe: an unknown raw value falls back to a defined default rather than
// crashing on an older build.

public enum Priority: String, Codable, CaseIterable, Sendable {
    case critical, high, normal, low

    /// Sort weight — lower sorts first.
    public var rank: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .normal: return 2
        case .low: return 3
        }
    }

    public var label: String {
        switch self {
        case .critical: return "Critical"
        case .high: return "High"
        case .normal: return "Normal"
        case .low: return "Low"
        }
    }
}

public enum ProjectStatus: String, Codable, CaseIterable, Sendable {
    case idea, planned, active, paused, completed, cancelled

    /// Only active projects are evaluated by the Attention Engine.
    public var isLive: Bool { self == .active }

    public var label: String {
        switch self {
        case .idea: return "Idea"
        case .planned: return "Planned"
        case .active: return "Active"
        case .paused: return "Paused"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

/// Never stored as a project's truth — it is computed from the Attention Engine.
/// The only stored health value is `Project.healthOverrideRaw`, which always
/// expires. See Section 6 and Appendix A.
public enum ProjectHealth: String, Codable, CaseIterable, Sendable {
    case onTrack, needsAttention, atRisk, blocked, completed

    public var label: String {
        switch self {
        case .onTrack: return "On Track"
        case .needsAttention: return "Needs Attention"
        case .atRisk: return "At Risk"
        case .blocked: return "Blocked"
        case .completed: return "Completed"
        }
    }
}

public enum TaskStatus: String, Codable, CaseIterable, Sendable {
    case inbox, next, scheduled, waiting, someday, done, cancelled

    public var isOpen: Bool { self != .done && self != .cancelled }

    public var label: String {
        switch self {
        case .inbox: return "Inbox"
        case .next: return "Next"
        case .scheduled: return "Scheduled"
        case .waiting: return "Waiting"
        case .someday: return "Someday"
        case .done: return "Done"
        case .cancelled: return "Cancelled"
        }
    }
}

/// Note there is no `overdue` case, on purpose.
///
/// Overdue is `dueDate < now && status is open` — computed on read, never
/// stored. A stored overdue flag goes stale the moment the app is closed, and
/// two devices would disagree about it.
public enum DelegationStatus: String, Codable, CaseIterable, Sendable {
    case delegated, acknowledged, inProgress, waiting, completed, cancelled

    public var isOpen: Bool { self != .completed && self != .cancelled }

    public var label: String {
        switch self {
        case .delegated: return "Delegated"
        case .acknowledged: return "Acknowledged"
        case .inProgress: return "In Progress"
        case .waiting: return "Waiting"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
}

public enum FollowUpStatus: String, Codable, CaseIterable, Sendable {
    case open, snoozed, completed, cancelled

    public var isOpen: Bool { self == .open || self == .snoozed }
}

public enum IdeaStatus: String, Codable, CaseIterable, Sendable {
    case new, reviewing, promoted, archived
}

public enum DecisionStatus: String, Codable, CaseIterable, Sendable {
    case pending, decided, revisited, abandoned

    /// `pending` *is* the "Decision Required" queue. There is no separate
    /// approvals model.
    public var needsMe: Bool { self == .pending }
}

public enum GoalHorizon: String, Codable, CaseIterable, Sendable {
    case quarter, year, multiYear
}

public enum GoalStatus: String, Codable, CaseIterable, Sendable {
    case active, achieved, missed, abandoned
}

/// Where a record came from. Used for diagnostics and for deciding whether a
/// record may be auto-modified by a sync pass.
public enum RecordSource: String, Codable, CaseIterable, Sendable {
    /// Typed or dictated inside the app.
    case app
    case manual, capture, siri, shortcut, widget, lockScreen, shareSheet, watch
    case meeting, reminder, email, system
}

public enum CaptureStatus: String, Codable, CaseIterable, Sendable {
    case unprocessed, proposed, confirmed, discarded
}

/// What kind of record a capture turned into.
public enum CaptureTargetType: String, Codable, CaseIterable, Sendable {
    case task, idea, note, followUp, delegation, decision, projectUpdate, none
}

/// How an event reached CEO OS. Under decision D2, Google calendars arrive as
/// `appleCalDAV` — the same path as any other account — and `googleDirect` is
/// unused unless the direct API is ever added.
public enum CalendarSourceSystem: String, Codable, CaseIterable, Sendable {
    case appleLocal, appleCloudKit, appleCalDAV, appleExchange, appleSubscribed, googleDirect, unknown
}

public enum ReminderLinkDirection: String, Codable, CaseIterable, Sendable {
    /// A CEO OS task mirrored out to Apple Reminders.
    case mirrorOut
    /// A reminder from the CEO OS Inbox list that became a task.
    case importedIn
}

public enum ReminderSyncState: String, Codable, CaseIterable, Sendable {
    case ok
    /// Both sides changed since the last sync. Surfaced, never auto-resolved.
    case conflict
    /// The reminder is gone. The task is kept; the link is surfaced for a
    /// one-tap Recreate or Unlink. Never auto-recreated — that is how you end
    /// up with fourteen copies.
    case detached
    case permissionLost
}

/// Ordered. `Comparable` so rules can take the worst signal on a subject.
public enum SignalSeverity: String, Codable, CaseIterable, Sendable, Comparable {
    case info, notice, warning, critical

    public var rank: Int {
        switch self {
        case .info: return 0
        case .notice: return 1
        case .warning: return 2
        case .critical: return 3
        }
    }

    public static func < (lhs: SignalSeverity, rhs: SignalSeverity) -> Bool {
        lhs.rank < rhs.rank
    }
}

/// The kinds of thing CEO OS may interrupt you about. Anything not in this list
/// is not allowed to become a notification — see Section 8.
public enum NotificationKind: String, Codable, CaseIterable, Sendable {
    case morningBrief, shutdownReview, weeklyReview
    case meetingPrep, calendarConflict, focusBlockStarting
    case delegationOverdue, followUpDue
    case decisionRequired, deadlineApproaching, projectAtRisk

    /// Scheduled rituals do not count against the event-driven daily budget.
    public var isScheduledRitual: Bool {
        self == .morningBrief || self == .shutdownReview || self == .weeklyReview
    }
}

public enum NotificationLevel: String, Codable, CaseIterable, Sendable {
    case off
    /// Never interrupts; folded into the next brief.
    case digest
    case immediate
}

/// Team-readiness hook C5. Everything is `privateToMe` until CEO OS has more
/// than one user, which it does not today.
public enum Visibility: String, Codable, CaseIterable, Sendable {
    case privateToMe, company
}

public enum AITier: String, Codable, CaseIterable, Sendable {
    case off
    /// Apple Foundation Models, on device. Nothing leaves the phone.
    case onDevice
    /// Opt-in, off by default, and never the source of a notification.
    case cloud
}

public enum FocusContext: String, Codable, CaseIterable, Sendable {
    case ceo, deepWork, meetings, travel, personal

    public var label: String {
        switch self {
        case .ceo: return "CEO Focus"
        case .deepWork: return "Deep Work"
        case .meetings: return "Meetings"
        case .travel: return "Travel"
        case .personal: return "Personal"
        }
    }
}

/// Identifies what a `StatusHistory` row or an `AttentionSignalRecord` is about.
/// Stored as a string rather than a relationship so one audit table can cover
/// every entity without twelve optional foreign keys.
public enum SubjectType: String, Codable, CaseIterable, Sendable {
    case company, person, project, milestone, task, delegation, followUp
    case idea, note, decision, meeting, goal, capture
}
