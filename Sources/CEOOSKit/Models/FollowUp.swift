import Foundation
import SwiftData

/// A conversation you owe someone, or one you want to come back to.
///
/// Distinct from `Delegation`: a delegation is work someone else has to do; a
/// follow-up is a conversation *you* have to start. Both appear on Waiting On,
/// but only delegations answer "who owes me what".
@Model
public final class FollowUp: CEOOSRecord, Completable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var completedAt: Date?

    public var subject: String = ""
    public var notes: String = ""
    public var dueDate: Date?
    /// Set when snoozed, so the Attention Engine can skip it without losing the
    /// original date.
    public var snoozedUntil: Date?

    public var statusRaw: String = FollowUpStatus.open.rawValue
    public var status: FollowUpStatus {
        get { FollowUpStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }

    /// An `EKRecurrenceRule`-style description for repeating follow-ups
    /// ("check in with Aaron every Monday"). Stored as text; CEO OS owns the
    /// schedule rather than delegating it to EventKit, because a recurring
    /// follow-up is not a reminder.
    public var recurrenceRule: String = ""

    public var sourceRaw: String = RecordSource.manual.rawValue
    public var source: RecordSource {
        get { RecordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public var originCaptureUUID: UUID?

    // MARK: Relationships

    public var person: Person?
    public var company: Company?
    public var project: Project?
    public var relatedMeeting: Meeting?
    /// Set when a decision produced this follow-up.
    public var sourceDecision: Decision?

    public func isDue(asOf now: Date = Date()) -> Bool {
        guard completedAt == nil, status.isOpen, let due = dueDate else { return false }
        if let snoozed = snoozedUntil, snoozed > now { return false }
        return due <= now
    }

    public init(subject: String, person: Person? = nil, dueDate: Date? = nil, source: RecordSource = .manual) {
        self.subject = subject
        self.person = person
        self.dueDate = dueDate
        self.sourceRaw = source.rawValue
    }
}
