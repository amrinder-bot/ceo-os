import Foundation
import SwiftData

/// A thought, captured before it is organised.
///
/// Ideas are deliberately cheap to create and cheap to ignore. The only
/// lifecycle that matters is `promoted` — an idea that became a project — and
/// the pointer to that project is a plain UUID rather than a relationship,
/// because it is provenance, not navigation.
@Model
public final class Idea: CEOOSRecord, Archivable {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""
    public var archivedAt: Date?

    public var title: String = ""
    public var body: String = ""
    public var topic: String = ""

    public var tagsRaw: String = ""
    public var tags: [String] {
        get { DelimitedList.decode(tagsRaw) }
        set { tagsRaw = DelimitedList.encode(newValue) }
    }

    public var statusRaw: String = IdeaStatus.new.rawValue
    public var status: IdeaStatus {
        get { IdeaStatus(rawValue: statusRaw) ?? .new }
        set { statusRaw = newValue.rawValue }
    }

    public var sourceRaw: String = RecordSource.manual.rawValue
    public var source: RecordSource {
        get { RecordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public var originCaptureUUID: UUID?
    public var promotedToProjectUUID: UUID?

    // MARK: Relationships

    public var company: Company?
    public var project: Project?
    public var person: Person?

    public init(title: String, body: String = "", source: RecordSource = .manual) {
        self.title = title
        self.body = body
        self.sourceRaw = source.rawValue
    }
}
