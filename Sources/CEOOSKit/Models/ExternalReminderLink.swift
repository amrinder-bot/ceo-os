import Foundation
import SwiftData

/// The one record that stops CEO OS and Apple Reminders duplicating each other
/// forever.
///
/// The loop it prevents: CEO OS writes a reminder → EventKit posts a change
/// notification → the app reads it as new → creates another task → writes
/// another reminder. `lastPushedFingerprint` breaks it. Before pushing, CEO OS
/// hashes the fields it owns; if the hash is unchanged, the write is skipped, so
/// our own echo is recognised and ignored.
///
/// Kept separate from `TaskItem` on purpose (Section 6, conflict rule 3): a
/// background sync writing to this record must not be able to overwrite a title
/// you are editing on another device.
@Model
public final class ExternalReminderLink: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    /// `EKReminder.calendarItemIdentifier`.
    public var reminderIdentifier: String = ""
    /// `EKCalendarItem.calendarItemExternalIdentifier`, stable across devices.
    public var externalIdentifier: String = ""
    public var listIdentifier: String = ""
    public var listTitle: String = ""

    public var directionRaw: String = ReminderLinkDirection.mirrorOut.rawValue
    public var direction: ReminderLinkDirection {
        get { ReminderLinkDirection(rawValue: directionRaw) ?? .mirrorOut }
        set { directionRaw = newValue.rawValue }
    }

    public var syncStateRaw: String = ReminderSyncState.ok.rawValue
    public var syncState: ReminderSyncState {
        get { ReminderSyncState(rawValue: syncStateRaw) ?? .ok }
        set { syncStateRaw = newValue.rawValue }
    }

    /// Hash of the fields CEO OS owns (title, due date, notes, priority) as of
    /// the last successful push. The echo-loop breaker.
    public var lastPushedFingerprint: String = ""
    public var lastPushedAt: Date?
    public var lastPulledAt: Date?
    /// Human-readable reason when `syncState` is not `ok`, shown on the task.
    public var lastErrorMessage: String = ""

    public var task: TaskItem?

    public init(reminderIdentifier: String, direction: ReminderLinkDirection = .mirrorOut) {
        self.reminderIdentifier = reminderIdentifier
        self.directionRaw = direction.rawValue
    }
}
