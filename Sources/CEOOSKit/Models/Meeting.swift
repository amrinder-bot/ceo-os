import Foundation
import SwiftData

/// A meeting, as CEO OS understands it — which is more than the calendar knows.
///
/// The calendar owns when it is and who is invited. CEO OS owns what it is
/// *for*: which project, what to prepare, and what came out of it. Those two
/// halves are joined by `calendarEventLink` and nothing is ever written back to
/// the event itself.
///
/// The debrief fields exist because most delegation is lost in the ten minutes
/// after a meeting ends.
@Model
public final class Meeting: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    public var title: String = ""
    public var startAt: Date?
    public var endAt: Date?
    public var location: String = ""

    /// What you want to have thought about before walking in. Rule R11 flags a
    /// linked meeting within 24 hours that has none.
    public var prepNotes: String = ""
    public var notes: String = ""
    public var isPrepared: Bool = false
    public var debriefCompletedAt: Date?

    // MARK: Relationships

    public var company: Company?
    public var project: Project?

    /// Inverse lives on `Person.meetings`.
    public var attendees: [Person] = []

    /// Cascade: the link record is a pointer owned by this meeting. Deleting it
    /// never touches the calendar event — see `CalendarEventLink`.
    @Relationship(deleteRule: .cascade, inverse: \CalendarEventLink.meeting)
    public var calendarEventLink: CalendarEventLink?

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.relatedMeeting)
    public var tasksCreated: [TaskItem] = []

    @Relationship(deleteRule: .nullify, inverse: \Decision.meeting)
    public var decisionsMade: [Decision] = []

    @Relationship(deleteRule: .nullify, inverse: \FollowUp.relatedMeeting)
    public var followUpsCreated: [FollowUp] = []

    @Relationship(deleteRule: .nullify, inverse: \Delegation.relatedMeeting)
    public var delegationsCreated: [Delegation] = []

    @Relationship(deleteRule: .nullify, inverse: \NoteItem.meeting)
    public var linkedNotes: [NoteItem] = []

    @Relationship(deleteRule: .cascade, inverse: \Attachment.meeting)
    public var attachments: [Attachment] = []

    public init(title: String, startAt: Date? = nil, endAt: Date? = nil) {
        self.title = title
        self.startAt = startAt
        self.endAt = endAt
    }
}
