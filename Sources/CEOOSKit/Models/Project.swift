import Foundation
import SwiftData

/// A project inside a company.
///
/// Note what is *not* stored here: health, risk, and "is it behind". Those are
/// computed by the Attention Engine on every read. Two devices can never
/// disagree about a project's health because neither one persists it — which is
/// how CloudKit's last-writer-wins is made safe (Section 6, rule 2).
@Model
public final class Project: CEOOSRecord, Archivable, Completable, VisibilityScoped {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var archivedAt: Date?
    public var completedAt: Date?
    public var visibilityRaw: String = Visibility.privateToMe.rawValue

    public var name: String = ""
    public var detail: String = ""
    public var notes: String = ""

    public var priorityRaw: String = Priority.normal.rawValue
    public var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .normal }
        set { priorityRaw = newValue.rawValue }
    }

    public var statusRaw: String = ProjectStatus.active.rawValue
    public var status: ProjectStatus {
        get { ProjectStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    public var startDate: Date?
    public var targetDate: Date?
    public var nextReviewDate: Date?

    /// 0–100. Compared against elapsed time by rule R5.
    public var percentComplete: Int = 0

    /// The four fields the weekly review checks for. An active project missing
    /// any of them is flagged by rule R14 rather than quietly drifting.
    public var nextActionText: String = ""
    public var blockerText: String = ""
    /// When the current blocker was first recorded. Rule R4 escalates on age,
    /// so this must not be inferred from `updatedAt`.
    public var blockerSince: Date?

    // MARK: Health override
    //
    // The only stored health value. Always time-boxed: an override with no
    // expiry would let a stale "it's fine" hide a real problem indefinitely,
    // which is the exact failure this product exists to prevent.

    public var healthOverrideRaw: String = ""
    public var healthOverrideReason: String = ""
    public var healthOverrideExpiresAt: Date?

    public var healthOverride: ProjectHealth? {
        get {
            guard !healthOverrideRaw.isEmpty else { return nil }
            if let expiry = healthOverrideExpiresAt, expiry < Date() { return nil }
            return ProjectHealth(rawValue: healthOverrideRaw)
        }
        set {
            healthOverrideRaw = newValue?.rawValue ?? ""
            if newValue == nil {
                healthOverrideReason = ""
                healthOverrideExpiresAt = nil
            }
        }
    }

    /// How far through the planned timeline we are, 0–1. `nil` when the project
    /// has no start or target date, which rule R5 treats as "cannot evaluate"
    /// rather than "on track".
    public var elapsedFraction: Double? {
        guard let start = startDate, let target = targetDate, target > start else { return nil }
        let total = target.timeIntervalSince(start)
        let done = Date().timeIntervalSince(start)
        return min(max(done / total, 0), 1)
    }

    // MARK: Relationships

    public var company: Company?
    public var owner: Person?
    public var participants: [Person] = []
    public var goals: [Goal] = []

    /// Cascade: a milestone has no meaning without its project.
    @Relationship(deleteRule: .cascade, inverse: \Milestone.project)
    public var milestones: [Milestone] = []

    /// Cascade for the same reason. Updates are append-only — they are never
    /// edited, so a sync conflict can never overwrite something you wrote.
    @Relationship(deleteRule: .cascade, inverse: \ProjectUpdate.project)
    public var updates: [ProjectUpdate] = []

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.project)
    public var tasks: [TaskItem] = []

    @Relationship(deleteRule: .nullify, inverse: \Idea.project)
    public var ideas: [Idea] = []

    @Relationship(deleteRule: .nullify, inverse: \NoteItem.project)
    public var linkedNotes: [NoteItem] = []

    @Relationship(deleteRule: .nullify, inverse: \Decision.project)
    public var decisions: [Decision] = []

    @Relationship(deleteRule: .nullify, inverse: \Meeting.project)
    public var meetings: [Meeting] = []

    @Relationship(deleteRule: .nullify, inverse: \Delegation.project)
    public var delegations: [Delegation] = []

    @Relationship(deleteRule: .nullify, inverse: \FollowUp.project)
    public var followUps: [FollowUp] = []

    @Relationship(deleteRule: .cascade, inverse: \Attachment.project)
    public var attachments: [Attachment] = []

    public init(name: String, company: Company? = nil, status: ProjectStatus = .active, priority: Priority = .normal) {
        self.name = name
        self.company = company
        self.statusRaw = status.rawValue
        self.priorityRaw = priority.rawValue
    }
}
