import Foundation
import SwiftData

/// A minimal audit trail: when did this go sideways.
///
/// Written only for project status and health transitions and delegation status
/// changes — not a general change log. The subject is identified by type plus
/// UUID rather than by twelve optional relationships, so one table covers every
/// entity.
///
/// Append-only, like `ProjectUpdate`.
@Model
public final class StatusHistory: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    public var subjectTypeRaw: String = SubjectType.project.rawValue
    public var subjectType: SubjectType {
        get { SubjectType(rawValue: subjectTypeRaw) ?? .project }
        set { subjectTypeRaw = newValue.rawValue }
    }

    public var subjectUUID: UUID?
    /// Denormalised so history stays readable after the subject is archived.
    public var subjectTitle: String = ""

    public var field: String = ""
    public var oldValue: String = ""
    public var newValue: String = ""
    public var changedAt: Date = Date()

    public init(subjectType: SubjectType, subjectUUID: UUID?, subjectTitle: String, field: String, oldValue: String, newValue: String) {
        self.subjectTypeRaw = subjectType.rawValue
        self.subjectUUID = subjectUUID
        self.subjectTitle = subjectTitle
        self.field = field
        self.oldValue = oldValue
        self.newValue = newValue
    }
}
