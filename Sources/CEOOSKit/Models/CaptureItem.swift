import Foundation
import SwiftData

/// The raw thing you said or typed, written to disk **before** anything tries
/// to understand it.
///
/// This is the safety net the whole product rests on. If the parser crashes,
/// the classifier is wrong, or the app is killed mid-capture, the words survive.
/// Everything after this record exists is an enhancement.
///
/// Append-only: a capture is never rewritten, only marked processed.
@Model
public final class CaptureItem: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    /// Exactly what was typed, or the transcript of what was said.
    public var rawText: String = ""
    /// Filename inside the App Group container, when a voice capture was kept.
    /// Deleted once the transcript is confirmed.
    public var audioFileName: String = ""
    public var capturedAt: Date = Date()

    public var sourceRaw: String = RecordSource.app.rawValue
    public var source: RecordSource {
        get { RecordSource(rawValue: sourceRaw) ?? .manual }
        set { sourceRaw = newValue.rawValue }
    }

    public var statusRaw: String = CaptureStatus.unprocessed.rawValue
    public var status: CaptureStatus {
        get { CaptureStatus(rawValue: statusRaw) ?? .unprocessed }
        set { statusRaw = newValue.rawValue }
    }

    /// The parser's proposal, as JSON, kept verbatim so a wrong classification
    /// can be inspected rather than guessed at.
    public var proposalJSON: String = ""
    /// 0–1. Below 0.5 the capture goes to the Inbox and asks nothing.
    public var parserConfidence: Double = 0

    public var materializedTypeRaw: String = CaptureTargetType.none.rawValue
    public var materializedType: CaptureTargetType {
        get { CaptureTargetType(rawValue: materializedTypeRaw) ?? .none }
        set { materializedTypeRaw = newValue.rawValue }
    }

    public var materializedUUID: UUID?
    public var processedAt: Date?

    public init(rawText: String, source: RecordSource = .app) {
        self.rawText = rawText
        self.sourceRaw = source.rawValue
    }
}
