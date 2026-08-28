import XCTest
import SwiftData
@testable import CEOOSKit

final class FirstRunSeederTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    func testSeedsOnceAndOnlyOnce() throws {
        let context = try makeContext()

        XCTAssertTrue(try FirstRunSeeder.seedIfNeeded(in: context))
        let companiesAfterFirst = try context.fetchCount(FetchDescriptor<Company>())
        let profilesAfterFirst = try context.fetchCount(FetchDescriptor<UserProfile>())

        XCTAssertFalse(
            try FirstRunSeeder.seedIfNeeded(in: context),
            "Seeding runs on every launch, so it has to be idempotent."
        )
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Company>()), companiesAfterFirst)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<UserProfile>()), profilesAfterFirst)
        XCTAssertEqual(profilesAfterFirst, 1)
    }

    func testEveryNotificationKindHasARule() throws {
        let context = try makeContext()
        try FirstRunSeeder.seedIfNeeded(in: context)

        let rules = try context.fetch(FetchDescriptor<NotificationRule>())
        let kinds = Set(rules.map(\.kind))
        XCTAssertEqual(
            kinds.count,
            NotificationKind.allCases.count,
            "Every kind needs a rule, or it silently has no settings and no ceiling."
        )
    }

    func testDefaultsAreConservative() {
        let rules = FirstRunSeeder.defaultNotificationRules()
        let immediate = rules.filter { $0.enabled && $0.level == .immediate }

        // Section 8: two scheduled rituals plus a small number of event-driven
        // kinds. If this count creeps up, the app is getting noisier — which is
        // the failure mode that gets it muted.
        XCTAssertLessThanOrEqual(immediate.count, 9, "Defaults are drifting towards notification overload.")

        let atRisk = rules.first { $0.kind == .projectAtRisk }
        XCTAssertEqual(atRisk?.minimumSeverity, .critical)

        let focus = rules.first { $0.kind == .focusBlockStarting }
        XCTAssertEqual(focus?.enabled, false, "You know you scheduled it. Off by default.")
    }

    func testStarterCompaniesAreOrdinaryEditableRecords() {
        let companies = FirstRunSeeder.starterCompanies()
        XCTAssertEqual(companies.count, 9)
        XCTAssertEqual(companies.map(\.sortOrder), Array(0..<9))
        XCTAssertTrue(companies.allSatisfy { !$0.name.isEmpty && !$0.shortName.isEmpty })
        XCTAssertTrue(
            companies.allSatisfy { !$0.isArchived },
            "Seeded companies are starting points, not fixtures."
        )
    }
}
