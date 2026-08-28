import Foundation
import SwiftData

/// A company is a first-class entity, not a tag.
///
/// It is also the unit CEO OS would share if it ever has more than one user —
/// team-readiness hook C4 — which is why every shareable record can reach a
/// Company.
@Model
public final class Company: CEOOSRecord, Archivable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var archivedAt: Date?

    public var name: String = ""
    /// Short form used in the UI and by Siri matching ("XPro Health" → "XPH").
    public var shortName: String = ""
    /// Extra names Siri and the capture parser should recognise, encoded with
    /// `DelimitedList`. Matching only — CEO OS never creates a company from
    /// speech.
    public var synonymsRaw: String = ""
    public var colorHex: String = "#8A8F98"
    public var symbolName: String = "building.2"
    public var isActive: Bool = true
    public var sortOrder: Int = 0
    public var notes: String = ""

    public var synonyms: [String] {
        get { DelimitedList.decode(synonymsRaw) }
        set { synonymsRaw = DelimitedList.encode(newValue) }
    }

    // MARK: Relationships
    // Nullify, not cascade: archiving or deleting a company must never take a
    // year of projects and decisions with it.

    @Relationship(deleteRule: .nullify, inverse: \Project.company)
    public var projects: [Project] = []

    @Relationship(deleteRule: .nullify, inverse: \Person.companies)
    public var people: [Person] = []

    @Relationship(deleteRule: .nullify, inverse: \Goal.company)
    public var goals: [Goal] = []

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.company)
    public var tasks: [TaskItem] = []

    @Relationship(deleteRule: .nullify, inverse: \Idea.company)
    public var ideas: [Idea] = []

    @Relationship(deleteRule: .nullify, inverse: \NoteItem.company)
    public var linkedNotes: [NoteItem] = []

    @Relationship(deleteRule: .nullify, inverse: \Decision.company)
    public var decisions: [Decision] = []

    @Relationship(deleteRule: .nullify, inverse: \Meeting.company)
    public var meetings: [Meeting] = []

    @Relationship(deleteRule: .nullify, inverse: \Delegation.company)
    public var delegations: [Delegation] = []

    @Relationship(deleteRule: .nullify, inverse: \FollowUp.company)
    public var followUps: [FollowUp] = []

    public init(name: String, shortName: String = "", colorHex: String = "#8A8F98", symbolName: String = "building.2", sortOrder: Int = 0) {
        self.name = name
        self.shortName = shortName.isEmpty ? name : shortName
        self.colorHex = colorHex
        self.symbolName = symbolName
        self.sortOrder = sortOrder
    }
}
