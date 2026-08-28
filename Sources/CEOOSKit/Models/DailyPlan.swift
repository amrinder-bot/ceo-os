import Foundation
import SwiftData

/// One day's plan: the Top 3, and whether the morning and evening rituals
/// happened.
@Model
public final class DailyPlan: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    /// Midnight of the day this plan is for, in the local calendar.
    public var date: Date = Date()

    public var briefGeneratedAt: Date?
    public var briefOpenedAt: Date?
    public var shutdownCompletedAt: Date?
    public var notes: String = ""

    @Relationship(deleteRule: .cascade, inverse: \PriorityItem.plan)
    public var priorities: [PriorityItem] = []

    public init(date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
    }
}

/// One of the day's three priorities.
///
/// Links to the underlying record by UUID rather than by relationship, because
/// a priority can point at a task, a project, or a decision, and SwiftData does
/// not model polymorphic relationships. Three nullable UUIDs is the honest
/// version of that.
@Model
public final class PriorityItem: CEOOSRecord, Completable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var completedAt: Date?

    public var sortOrder: Int = 0
    /// Denormalised so the widget and the Lock Screen can render without
    /// resolving the linked record — and so the plan still reads correctly if
    /// the underlying record is later archived.
    public var title: String = ""

    public var linkedTaskUUID: UUID?
    public var linkedProjectUUID: UUID?
    public var linkedDecisionUUID: UUID?

    public var plan: DailyPlan?

    public init(title: String, sortOrder: Int = 0) {
        self.title = title
        self.sortOrder = sortOrder
    }
}
