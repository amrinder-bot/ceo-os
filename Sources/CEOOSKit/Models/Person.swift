import Foundation
import SwiftData

/// Someone you work with.
///
/// A Person is a CEO OS record, not a Contacts record. `contactIdentifier` is an
/// optional link used to fill in details on creation; CEO OS never writes to
/// Contacts, and a person continues to exist if the contact is deleted.
@Model
public final class Person: CEOOSRecord, Archivable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var archivedAt: Date?

    public var name: String = ""
    public var role: String = ""
    public var email: String = ""
    public var phone: String = ""
    public var notes: String = ""
    /// False for lawyers, vendors, landlords — anyone outside your companies.
    public var isInternal: Bool = true

    /// `CNContact.identifier`, when you linked one. Empty otherwise.
    public var contactIdentifier: String = ""

    /// Names Siri and the capture parser should also match ("Raf" → Rafael).
    /// Matching only — CEO OS never creates a Person from speech, because a
    /// mis-transcription would otherwise silently invent someone.
    public var synonymsRaw: String = ""
    public var synonyms: [String] {
        get { DelimitedList.decode(synonymsRaw) }
        set { synonymsRaw = DelimitedList.encode(newValue) }
    }

    /// Which company this person mainly belongs to. Stored as a plain UUID
    /// rather than a second relationship to Company, because a second
    /// Person↔Company relationship would need its own inverse collection and
    /// buys nothing.
    public var primaryCompanyUUID: UUID?

    /// Team-readiness hook C2. Always nil today. This is the field that lets a
    /// contact become someone who can sign in, without merging two tables
    /// later.
    public var userAccountID: String?

    // MARK: Relationships

    public var companies: [Company] = []

    @Relationship(deleteRule: .nullify, inverse: \Project.owner)
    public var projectsOwned: [Project] = []

    @Relationship(deleteRule: .nullify, inverse: \Project.participants)
    public var projectsParticipating: [Project] = []

    @Relationship(deleteRule: .nullify, inverse: \Delegation.assignedTo)
    public var delegations: [Delegation] = []

    @Relationship(deleteRule: .nullify, inverse: \FollowUp.person)
    public var followUps: [FollowUp] = []

    @Relationship(deleteRule: .nullify, inverse: \Meeting.attendees)
    public var meetings: [Meeting] = []

    @Relationship(deleteRule: .nullify, inverse: \Decision.peopleInvolved)
    public var decisionsInvolved: [Decision] = []

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.assignee)
    public var tasksAssigned: [TaskItem] = []

    @Relationship(deleteRule: .nullify, inverse: \ProjectUpdate.author)
    public var projectUpdates: [ProjectUpdate] = []

    @Relationship(deleteRule: .nullify, inverse: \Idea.person)
    public var ideas: [Idea] = []

    @Relationship(deleteRule: .nullify, inverse: \NoteItem.person)
    public var linkedNotes: [NoteItem] = []

    public init(name: String, role: String = "", isInternal: Bool = true) {
        self.name = name
        self.role = role
        self.isInternal = isInternal
    }
}
