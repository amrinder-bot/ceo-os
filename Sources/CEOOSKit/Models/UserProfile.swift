import Foundation
import SwiftData

/// Your settings. One record, created on first launch.
///
/// Times of day are stored as minutes from midnight rather than `Date`, because
/// a `Date` carries a calendar day that means nothing for "the brief fires at
/// 7am" and goes wrong across time zones and daylight saving.
@Model
public final class UserProfile: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    public var displayName: String = ""

    // MARK: Rhythm

    public var workdayStartMinute: Int = 8 * 60
    public var workdayEndMinute: Int = 18 * 60
    public var briefMinute: Int = 7 * 60
    public var shutdownMinute: Int = 18 * 60
    /// 1 = Sunday, matching `Calendar.component(.weekday:)`. 6 = Friday.
    public var weeklyReviewWeekday: Int = 6
    public var weeklyReviewMinute: Int = 16 * 60

    // MARK: Notifications

    /// Hard ceiling on event-driven interruptions per day. Scheduled rituals
    /// (brief, shutdown, weekly review) do not count against it. See Section 8.
    public var dailyNotificationBudget: Int = 4
    /// Suspends everything except the morning brief and meeting prep.
    public var quietWeekEnabled: Bool = false

    // MARK: Security

    public var appLockEnabled: Bool = false
    /// Seconds in the background before the lock re-arms.
    public var appLockGracePeriod: Int = 60

    // MARK: Work defaults

    public var defaultFocusBlockMinutes: Int = 90
    /// EventKit identifier of the calendar focus blocks are written to.
    /// Empty until you choose one. CEO OS never picks silently — see Section 6.
    public var focusBlockCalendarIdentifier: String = ""
    /// EventKit identifier of the Reminders list watched for inbound captures.
    public var reminderInboxListIdentifier: String = ""

    // MARK: AI

    /// `off` until Phase 2. `onDevice` keeps everything on the phone.
    public var aiTierRaw: String = AITier.off.rawValue
    public var aiTier: AITier {
        get { AITier(rawValue: aiTierRaw) ?? .off }
        set { aiTierRaw = newValue.rawValue }
    }

    public var focusContextRaw: String = FocusContext.ceo.rawValue
    public var focusContext: FocusContext {
        get { FocusContext(rawValue: focusContextRaw) ?? .ceo }
        set { focusContextRaw = newValue.rawValue }
    }

    public init(displayName: String = "") {
        self.displayName = displayName
    }
}
