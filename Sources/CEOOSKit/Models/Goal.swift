import Foundation
import SwiftData

/// A quarterly or annual outcome, with projects hung off it.
@Model
public final class Goal: CEOOSRecord, Archivable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var archivedAt: Date?

    public var title: String = ""
    public var detail: String = ""
    public var targetDate: Date?

    public var horizonRaw: String = GoalHorizon.quarter.rawValue
    public var horizon: GoalHorizon {
        get { GoalHorizon(rawValue: horizonRaw) ?? .quarter }
        set { horizonRaw = newValue.rawValue }
    }

    public var statusRaw: String = GoalStatus.active.rawValue
    public var status: GoalStatus {
        get { GoalStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    /// Free text — "monthly recurring revenue", "locations open". Kept as a
    /// description plus two numbers rather than a metrics engine, because this
    /// is a goal list, not a BI tool.
    public var metricDescription: String = ""
    public var targetValue: Double = 0
    public var currentValue: Double = 0

    public var company: Company?

    @Relationship(deleteRule: .nullify, inverse: \Project.goals)
    public var projects: [Project] = []

    public init(title: String, horizon: GoalHorizon = .quarter) {
        self.title = title
        self.horizonRaw = horizon.rawValue
    }
}
