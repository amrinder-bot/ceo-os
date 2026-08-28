import Foundation
import SwiftData

/// Longer-form written content, linked to whatever it is about.
///
/// Named `NoteItem` for symmetry with `TaskItem` and to keep `Note` free.
///
/// `body` is the one genuinely editable long-text field in the schema, which
/// makes it the one place a CloudKit last-writer-wins conflict could lose a
/// paragraph. Accepted knowingly: notes are edited from one device at a time in
/// practice, and the alternative — append-only note fragments — makes ordinary
/// editing worse for a risk that is rare. Anything written *once* (project
/// updates, decision rationale, captures) is append-only instead.
@Model
public final class NoteItem: CEOOSRecord, Archivable, VisibilityScoped {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var archivedAt: Date?
    public var visibilityRaw: String = Visibility.privateToMe.rawValue

    public var title: String = ""
    /// Markdown.
    public var body: String = ""
    public var updatedAt: Date = Date()

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

    public var originCaptureUUID: UUID?

    // MARK: Relationships

    public var company: Company?
    public var project: Project?
    public var person: Person?
    public var meeting: Meeting?
    public var decision: Decision?

    @Relationship(deleteRule: .nullify, inverse: \TaskItem.relatedNote)
    public var linkedTasks: [TaskItem] = []

    @Relationship(deleteRule: .cascade, inverse: \Attachment.note)
    public var attachments: [Attachment] = []

    public init(title: String, body: String = "", source: RecordSource = .manual) {
        self.title = title
        self.body = body
        self.sourceRaw = source.rawValue
    }
}
