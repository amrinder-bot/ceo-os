import Foundation
import SwiftData

/// Something you asked someone else to do.
///
/// This is the entity the whole "Waiting On" screen is built from, and the one
/// that answers *who owes me what*. It is deliberately separate from
/// `TaskItem`: your work and other people's work need different views,
/// different overdue behaviour, and different notifications.
///
/// `followUpDate` is the date you want to be reminded to chase — normally
/// earlier than `dueDate`, because a nudge the day after it was due is already
/// late.
@Model
public final class Delegation: CEOOSRecord, Completable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var completedAt: Date?

    public var what: String = ""
    public var notes: String = ""

    public var delegatedAt: Date = Date()
    public var dueDate: Date?
    public var followUpDate: Date?
    /// When you last chased. Used to avoid nudging the same person twice in a
    /// day, and to show "chased 3 times" on the detail screen.
    public var lastNudgeAt: Date?

    public var statusRaw: String = DelegationStatus.delegated.rawValue
    public var status: DelegationStatus {
        get { DelegationStatus(rawValue: statusRaw) ?? .delegated }
        set { statusRaw = newValue.rawValue }
    }

    public var sourceRaw: String = RecordSource.manual.rawValue
    public var source: RecordSource {
        get { RecordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public var originCaptureUUID: UUID?

    // MARK: Relationships

    public var assignedTo: Person?
    public var company: Company?
    public var project: Project?
    public var relatedMeeting: Meeting?

    /// There is no `.overdue` status, on purpose. Overdue is a fact about the
    /// clock, not a state someone moved this record into — so it is computed on
    /// every read and can never be stale or disagreed about across devices.
    public func isOverdue(asOf now: Date = Date()) -> Bool {
        guard completedAt == nil, status.isOpen, let due = dueDate else { return false }
        return due < now
    }

    public func daysLate(asOf now: Date = Date()) -> Int {
        guard let due = dueDate, isOverdue(asOf: now) else { return 0 }
        return Calendar.current.dateComponents([.day], from: due, to: now).day ?? 0
    }

    public init(what: String, assignedTo: Person? = nil, dueDate: Date? = nil, source: RecordSource = .manual) {
        self.what = what
        self.assignedTo = assignedTo
        self.dueDate = dueDate
        self.sourceRaw = source.rawValue
    }
}
