import Foundation
import SwiftData

/// A dated checkpoint inside a project. Overdue milestones are the single
/// strongest risk signal in the system (rule R2).
@Model
public final class Milestone: CEOOSRecord, Completable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var completedAt: Date?

    public var title: String = ""
    public var detail: String = ""
    public var dueDate: Date?
    public var sortOrder: Int = 0

    public var project: Project?

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.milestone)
    public var tasks: [TaskItem] = []

    /// Computed, never stored — see `DelegationStatus` for why.
    public func isOverdue(asOf now: Date = Date()) -> Bool {
        guard completedAt == nil, let due = dueDate else { return false }
        return due < now
    }

    public init(title: String, dueDate: Date? = nil, sortOrder: Int = 0) {
        self.title = title
        self.dueDate = dueDate
        self.sortOrder = sortOrder
    }
}
