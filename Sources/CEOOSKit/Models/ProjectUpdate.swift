import Foundation
import SwiftData

/// A dated note on where a project stands. **Append-only.**
///
/// Updates are never edited or merged. That is deliberate: editing shared text
/// from two devices inside one CloudKit sync window loses a version silently,
/// so anything narrative is written as a new record instead. Posting two
/// updates from two devices loses nothing.
///
/// Posting an update is also what clears rule R1 ("no update in N days"), so
/// this record is what keeps project health honest.
@Model
public final class ProjectUpdate: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    public var body: String = ""

    /// Snapshot of the project at the moment of writing, so the history reads
    /// truthfully later even though health itself is never stored on Project.
    public var percentCompleteAtUpdate: Int = 0
    public var computedHealthAtUpdate: String = ""

    public var sourceRaw: String = RecordSource.manual.rawValue
    public var source: RecordSource {
        get { RecordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public var project: Project?
    public var author: Person?

    public init(body: String, percentCompleteAtUpdate: Int = 0, source: RecordSource = .manual) {
        self.body = body
        self.percentCompleteAtUpdate = percentCompleteAtUpdate
        self.sourceRaw = source.rawValue
    }
}
