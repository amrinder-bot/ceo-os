import Foundation
import SwiftData

/// Your settings for one kind of interruption.
///
/// One record per `NotificationKind`, created with conservative defaults on
/// first launch. The product ships quieter than feels right and turns things up
/// on request — notification fatigue is the failure mode that kills this app,
/// because a muted CEO OS is a CEO OS that has stopped working.
@Model
public final class NotificationRule: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    public var kindRaw: String = NotificationKind.morningBrief.rawValue
    public var kind: NotificationKind {
        get { NotificationKind(rawValue: kindRaw) ?? .morningBrief }
        set { kindRaw = newValue.rawValue }
    }

    public var enabled: Bool = true

    public var levelRaw: String = NotificationLevel.digest.rawValue
    public var level: NotificationLevel {
        get { NotificationLevel(rawValue: levelRaw) ?? .digest }
        set { levelRaw = newValue.rawValue }
    }

    /// For scheduled rituals: minutes from midnight. Ignored otherwise.
    public var fireMinute: Int = 7 * 60
    /// For event-driven kinds: how far ahead to fire (meeting prep = 30).
    public var leadTimeMinutes: Int = 30
    /// Signals below this never interrupt, whatever the level.
    public var minimumSeverityRaw: String = SignalSeverity.warning.rawValue
    public var minimumSeverity: SignalSeverity {
        get { SignalSeverity(rawValue: minimumSeverityRaw) ?? .warning }
        set { minimumSeverityRaw = newValue.rawValue }
    }
    /// Do not repeat the same signal inside this window unless it got worse.
    public var cooldownHours: Int = 24
    public var maxPerDay: Int = 1

    public init(kind: NotificationKind, enabled: Bool = true, level: NotificationLevel = .digest) {
        self.kindRaw = kind.rawValue
        self.enabled = enabled
        self.levelRaw = level.rawValue
    }
}
