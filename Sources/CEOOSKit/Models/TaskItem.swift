import Foundation
import SwiftData

/// Something *you* need to do.
///
/// Named `TaskItem` rather than `Task` because `Task` is Swift concurrency's
/// type, and shadowing it across a whole framework is a recipe for confusing
/// errors at every call site.
///
/// If the work belongs to someone else, it is a `Delegation`, not a task with
/// an assignee. `assignee` exists for the case where you are tracking who is
/// doing a piece of your own work; the UI offers to convert to a Delegation
/// when the assignee is not you, because "who owes me what" is the question
/// that has to be answerable.
@Model
public final class TaskItem: CEOOSRecord, Completable, VisibilityScoped {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var completedAt: Date?
    public var visibilityRaw: String = Visibility.privateToMe.rawValue

    public var title: String = ""
    public var details: String = ""

    public var priorityRaw: String = Priority.normal.rawValue
    public var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .normal }
        set { priorityRaw = newValue.rawValue }
    }

    public var statusRaw: String = TaskStatus.inbox.rawValue
    public var status: TaskStatus {
        get { TaskStatus(rawValue: statusRaw) ?? .inbox }
        set { statusRaw = newValue.rawValue }
    }

    public var dueDate: Date?
    /// Hide until this date. Powers the Someday view without a second list.
    public var deferUntil: Date?
    /// When to be reminded. Distinct from `dueDate` — you often want warning
    /// before the deadline, not at it.
    public var reminderAt: Date?
    public var estimatedMinutes: Int = 0

    /// Encoded with `DelimitedList` so `#Predicate` can filter on it.
    public var tagsRaw: String = ""
    public var tags: [String] {
        get { DelimitedList.decode(tagsRaw) }
        set { tagsRaw = DelimitedList.encode(newValue) }
    }

    public var sourceRaw: String = RecordSource.manual.rawValue
    public var source: RecordSource {
        get { RecordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    /// Provenance pointer to the raw capture this came from, if any. A plain
    /// UUID rather than a relationship: six materialised types would otherwise
    /// need six inverse collections on `CaptureItem` for something that is only
    /// ever read from one screen.
    public var originCaptureUUID: UUID?

    // MARK: Relationships

    public var company: Company?
    public var project: Project?
    public var milestone: Milestone?
    public var assignee: Person?
    public var relatedMeeting: Meeting?
    public var relatedNote: NoteItem?

    /// The link to a mirrored Apple Reminder, when one exists.
    ///
    /// Deliberately a separate record: a background mirror-sync write must not
    /// be able to clobber a title you are editing on another device
    /// (Section 6, conflict rule 3). Cascade, because the link has no meaning
    /// without the task — note that deleting the link never deletes the
    /// reminder itself.
    @Relationship(deleteRule: .cascade, inverse: \ExternalReminderLink.task)
    public var reminderLink: ExternalReminderLink?

    /// Computed, never stored.
    public func isOverdue(asOf now: Date = Date()) -> Bool {
        guard completedAt == nil, status.isOpen, let due = dueDate else { return false }
        return due < now
    }

    public init(title: String, status: TaskStatus = .inbox, priority: Priority = .normal, dueDate: Date? = nil, source: RecordSource = .manual) {
        self.title = title
        self.statusRaw = status.rawValue
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
        self.sourceRaw = source.rawValue
    }
}
