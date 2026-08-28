import Foundation
import SwiftData

/// A pointer to a calendar event, plus enough cached detail to render it
/// offline. **Never the source of truth for event content.**
///
/// EventKit owns the event. CEO OS owns the meaning attached to it. That split
/// is what makes rule 8 of the development rules enforceable — CEO OS cannot
/// silently modify external calendar data if it never stores it as truth.
///
/// Under decision D2 every calendar reaches CEO OS through EventKit, including
/// Google's, so there is one code path here regardless of provider.
@Model
public final class CalendarEventLink: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    /// `EKEvent.eventIdentifier`. Device-local and not stable across accounts,
    /// which is why `iCalUID` exists alongside it.
    public var eventIdentifier: String = ""
    /// `EKCalendarItem.calendarItemExternalIdentifier` — the iCalendar UID.
    /// Stable across devices and across the CalDAV bridge, so this is the key
    /// that would resolve Apple/Google duplicates if the direct Google API were
    /// ever added (Section 6).
    public var iCalUID: String = ""
    public var calendarIdentifier: String = ""
    public var calendarTitle: String = ""

    public var sourceSystemRaw: String = CalendarSourceSystem.unknown.rawValue
    public var sourceSystem: CalendarSourceSystem {
        get { CalendarSourceSystem(rawValue: sourceSystemRaw) ?? .unknown }
        set { sourceSystemRaw = newValue.rawValue }
    }

    /// For a recurring series, the start of *this* occurrence. Every instance
    /// shares one `iCalUID`, so identity is the pair, not the UID alone.
    public var occurrenceStart: Date?
    public var recurrenceMasterUID: String = ""

    /// True only for events CEO OS itself created — currently focus blocks.
    /// Every write path is gated on this at the service layer, not just hidden
    /// in the UI: CEO OS must never edit or delete an event it did not create.
    public var isCEOOSOwned: Bool = false

    // Cached for offline display. Refreshed on every sync pass; never written
    // back to the event.
    public var cachedTitle: String = ""
    public var cachedStart: Date?
    public var cachedEnd: Date?
    public var cachedIsAllDay: Bool = false
    public var cachedLocation: String = ""
    public var cachedAttendeeCount: Int = 0
    public var lastSyncedAt: Date?

    /// Reserved for the deduplication fingerprint described in Section 6. Unused
    /// while EventKit is the only read path, and populated the day a second one
    /// exists.
    public var fingerprint: String = ""

    public var meeting: Meeting?

    public init(eventIdentifier: String, iCalUID: String = "") {
        self.eventIdentifier = eventIdentifier
        self.iCalUID = iCalUID
    }
}
