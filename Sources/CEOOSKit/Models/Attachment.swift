import Foundation
import SwiftData

/// A file attached to a note, project, meeting, or decision.
///
/// `fileData` uses `.externalStorage`, so SwiftData keeps the bytes beside the
/// database rather than inside it and CloudKit mirrors them as assets. Without
/// that, a handful of photographs would bloat every sync.
@Model
public final class Attachment: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    public var filename: String = ""
    /// Uniform type identifier, e.g. "public.png".
    public var uti: String = ""
    public var byteCount: Int = 0

    @Attribute(.externalStorage)
    public var fileData: Data?

    /// Small enough to live inline so lists render without loading the asset.
    public var thumbnailData: Data?

    // Exactly one of these is set. Four nullable parents rather than a
    // polymorphic owner, which SwiftData does not support.
    public var note: NoteItem?
    public var project: Project?
    public var meeting: Meeting?
    public var decision: Decision?

    public init(filename: String, uti: String = "", fileData: Data? = nil) {
        self.filename = filename
        self.uti = uti
        self.fileData = fileData
        self.byteCount = fileData?.count ?? 0
    }
}
