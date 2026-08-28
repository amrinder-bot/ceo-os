import Foundation
import SwiftData

/// Creates the records the app needs to exist on first launch.
///
/// The companies below are **starting points, not fixtures**. They are ordinary
/// editable records: rename them, archive them, add more. Nothing in the code
/// refers to a company by name.
///
/// Notification defaults are deliberately quieter than they probably need to be.
/// It is easy to turn one on when you notice it missing, and very hard to
/// recover trust in an app you have muted.
public enum FirstRunSeeder {

    /// Seeds only when the store has never been set up. Safe to call on every
    /// launch, and it is: presence of a `UserProfile` is the marker, so a
    /// second device that has already synced does not re-seed.
    @discardableResult
    public static func seedIfNeeded(in context: ModelContext) throws -> Bool {
        let existing = try context.fetch(FetchDescriptor<UserProfile>())
        guard existing.isEmpty else { return false }

        let profile = UserProfile()
        context.insert(profile)

        for rule in defaultNotificationRules() {
            context.insert(rule)
        }

        // Only seed companies into a genuinely empty store. If CloudKit has
        // already delivered records from another device, leave them alone.
        let companyCount = try context.fetchCount(FetchDescriptor<Company>())
        if companyCount == 0 {
            for company in starterCompanies() {
                context.insert(company)
            }
        }

        try context.save()
        return true
    }

    static func defaultNotificationRules() -> [NotificationRule] {
        [
            // The one guaranteed daily interruption.
            rule(.morningBrief, level: .immediate, fireMinute: 7 * 60, minimum: .info, maxPerDay: 1),
            rule(.shutdownReview, level: .immediate, fireMinute: 18 * 60, minimum: .info, maxPerDay: 1),
            rule(.weeklyReview, level: .immediate, fireMinute: 16 * 60, minimum: .info, maxPerDay: 1),

            // Time-critical and genuinely actionable in the moment.
            rule(.meetingPrep, level: .immediate, lead: 30, minimum: .notice, maxPerDay: 3),
            rule(.calendarConflict, level: .immediate, minimum: .warning, maxPerDay: 2),

            // The delegation loop — the reason this product exists.
            rule(.delegationOverdue, level: .immediate, minimum: .warning, maxPerDay: 1),

            // Real, but rarely urgent enough to interrupt. Folded into the brief.
            rule(.followUpDue, level: .digest, minimum: .notice, maxPerDay: 1),

            rule(.decisionRequired, level: .immediate, minimum: .warning, maxPerDay: 1),
            rule(.deadlineApproaching, level: .immediate, minimum: .warning, maxPerDay: 2),
            // Fires on the transition into At Risk, never while it stays there.
            rule(.projectAtRisk, level: .immediate, minimum: .critical, maxPerDay: 2),

            // Off by default. You know you scheduled it.
            rule(.focusBlockStarting, enabled: false, level: .digest, lead: 5, minimum: .info, maxPerDay: 4),
        ]
    }

    private static func rule(
        _ kind: NotificationKind,
        enabled: Bool = true,
        level: NotificationLevel,
        fireMinute: Int = 7 * 60,
        lead: Int = 30,
        minimum: SignalSeverity,
        maxPerDay: Int
    ) -> NotificationRule {
        let rule = NotificationRule(kind: kind, enabled: enabled, level: level)
        rule.fireMinute = fireMinute
        rule.leadTimeMinutes = lead
        rule.minimumSeverity = minimum
        rule.maxPerDay = maxPerDay
        return rule
    }

    static func starterCompanies() -> [Company] {
        let specs: [(String, String, String, String, [String])] = [
            ("Kamboj Ventures",         "Ventures",   "#C9A227", "building.columns",        ["KV", "Kamboj"]),
            ("Kamboj Advisory",         "Advisory",   "#8E7CC3", "person.2.badge.gearshape", ["KA"]),
            ("Kamboj Capital Solutions","Capital",    "#3D7A5A", "chart.line.uptrend.xyaxis", ["KCS", "Capital Solutions"]),
            ("XPro Health",             "Health",     "#2F7D8F", "heart.text.square",       ["XPH", "XPro Med"]),
            ("XPro Vault",              "Vault",      "#5B6B8C", "lock.square.stack",       ["XPV", "Vault"]),
            ("XPro Jets",               "Jets",       "#9A6E1F", "airplane",                ["XPJ", "Aviation", "XPro Aviation"]),
            ("XPro Events",             "Events",     "#B5533C", "sparkles.rectangle.stack", ["XPE", "Events"]),
            ("E-Commerce",              "Commerce",   "#4A7C59", "cart",                    ["Ecom", "E Commerce"]),
            ("XPro Fulfillment",        "Fulfillment","#6B6F76", "shippingbox",             ["XPF", "Fulfilment"]),
        ]

        return specs.enumerated().map { index, spec in
            let company = Company(
                name: spec.0,
                shortName: spec.1,
                colorHex: spec.2,
                symbolName: spec.3,
                sortOrder: index
            )
            company.synonyms = spec.4
            return company
        }
    }
}
