import Foundation
import SwiftData

/// Why something was decided, recorded at the time it was decided.
///
/// This entity does double duty. `status == .pending` **is** the "Decision
/// Required" queue on the dashboard — there is no separate approvals model,
/// because a decision waiting on you and a decision you already made are the
/// same thing at different points in its life.
///
/// `context` and `rationale` are written once, at decision time, and treated as
/// append-only in practice: the UI does not offer to rewrite history.
@Model
public final class Decision: CEOOSRecord, VisibilityScoped {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var visibilityRaw: String = Visibility.privateToMe.rawValue

    public var title: String = ""
    /// What was going on that made this necessary.
    public var context: String = ""
    /// Why this option and not another. The field that stops you re-litigating
    /// a decision in six months because you cannot remember the reasoning.
    public var rationale: String = ""
    public var alternativesConsidered: String = ""

    public var statusRaw: String = DecisionStatus.pending.rawValue
    public var status: DecisionStatus {
        get { DecisionStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    public var decidedOn: Date?
    /// The date by which you need to have decided. Drives rule R9's escalation.
    public var neededBy: Date?
    public var followUpRequired: Bool = false

    public var sourceRaw: String = RecordSource.manual.rawValue
    public var source: RecordSource {
        get { RecordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public var originCaptureUUID: UUID?

    // MARK: Relationships

    public var company: Company?
    public var project: Project?
    public var meeting: Meeting?

    /// Inverse lives on `Person.decisionsInvolved`.
    public var peopleInvolved: [Person] = []

    @Relationship(deleteRule: .nullify, inverse: \NoteItem.decision)
    public var supportingNotes: [NoteItem] = []

    @Relationship(deleteRule: .nullify, inverse: \FollowUp.sourceDecision)
    public var resultingFollowUps: [FollowUp] = []

    @Relationship(deleteRule: .cascade, inverse: \Attachment.decision)
    public var attachments: [Attachment] = []

    /// How long this has been sitting on you. Rule R9 escalates on age as well
    /// as on `neededBy`, because the decisions that hurt are the ones nobody
    /// set a deadline for.
    public func ageInDays(asOf now: Date = Date()) -> Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: now).day ?? 0
    }

    public init(title: String, status: DecisionStatus = .pending, source: RecordSource = .manual) {
        self.title = title
        self.statusRaw = status.rawValue
        self.sourceRaw = source.rawValue
    }
}
