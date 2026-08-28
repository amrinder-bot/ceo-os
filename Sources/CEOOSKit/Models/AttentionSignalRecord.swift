import Foundation
import SwiftData

/// Persistence for a signal the Attention Engine produced.
///
/// The engine itself is stateless — every signal is recomputed from the
/// database on demand, so nothing here is a source of truth about whether
/// something is wrong. This record exists for three things the engine cannot do
/// without memory:
///
/// 1. **Notification dedup** — do not tell me the same thing twice today.
/// 2. **Snooze and dismiss** — and have that follow me to my other devices.
/// 3. **"New since yesterday"** — `firstDetectedAt` is what makes a project
///    entering At Risk distinguishable from one that has been there a week,
///    which is the difference between a useful alert and noise.
@Model
public final class AttentionSignalRecord: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    /// Stable identity for "this rule, about this record" — the same string
    /// every time the condition recurs. Used as the notification identifier so
    /// rescheduling replaces rather than duplicates.
    public var signalKey: String = ""
    /// Which rule produced it: "R2", "R7", … See Appendix A.
    public var ruleID: String = ""

    public var severityRaw: String = SignalSeverity.notice.rawValue
    public var severity: SignalSeverity {
        get { SignalSeverity(rawValue: severityRaw) ?? .notice }
        set { severityRaw = newValue.rawValue }
    }

    public var subjectTypeRaw: String = SubjectType.project.rawValue
    public var subjectType: SubjectType {
        get { SubjectType(rawValue: subjectTypeRaw) ?? .project }
        set { subjectTypeRaw = newValue.rawValue }
    }

    public var subjectUUID: UUID?
    public var subjectTitle: String = ""

    /// The sentence shown to you, already composed: "Milestone 3 is 4 days
    /// overdue". Explanations are built by the rule that fired, never by a
    /// model, and never by a score.
    public var explanation: String = ""

    /// UUIDs of the records that justify the claim, encoded with
    /// `DelimitedList`. Every line in the dashboard, brief, and AI answer taps
    /// through to these.
    public var evidenceRaw: String = ""
    public var evidenceUUIDs: [String] {
        get { DelimitedList.decode(evidenceRaw) }
        set { evidenceRaw = DelimitedList.encode(newValue) }
    }

    public var firstDetectedAt: Date = Date()
    public var lastSeenAt: Date = Date()
    public var resolvedAt: Date?
    public var snoozedUntil: Date?
    public var dismissedAt: Date?

    public var lastNotifiedAt: Date?
    /// How many times this exact signal has interrupted you. Part of the
    /// interruption budget in Section 8.
    public var notifyCount: Int = 0
    /// Severity at the moment of the last notification. A signal may interrupt
    /// again inside its cooldown only if it has got worse.
    public var notifiedSeverityRaw: String = ""

    public var isActionable: Bool {
        resolvedAt == nil && dismissedAt == nil && (snoozedUntil ?? .distantPast) < Date()
    }

    public init(signalKey: String, ruleID: String, severity: SignalSeverity, subjectType: SubjectType, subjectUUID: UUID?, subjectTitle: String, explanation: String) {
        self.signalKey = signalKey
        self.ruleID = ruleID
        self.severityRaw = severity.rawValue
        self.subjectTypeRaw = subjectType.rawValue
        self.subjectUUID = subjectUUID
        self.subjectTitle = subjectTitle
        self.explanation = explanation
    }
}
