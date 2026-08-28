import XCTest
import SwiftData
@testable import CEOOSKit

/// Covers the behaviour that the schema deliberately does *not* store, because
/// getting these wrong is how a dashboard starts lying.
final class ModelBehaviourTests: XCTestCase {

    private func makeContext() throws -> ModelContext {
        let schema = Schema(versionedSchema: SchemaV1.self)
        let container = try ModelContainer(
            for: schema,
            configurations: ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    private func date(daysFromNow days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }

    // MARK: Overdue is computed, never stored

    func testDelegationOverdueIsComputedFromTheClock() {
        let delegation = Delegation(what: "Lease numbers", dueDate: date(daysFromNow: -3))
        XCTAssertTrue(delegation.isOverdue())
        XCTAssertEqual(delegation.daysLate(), 3)

        // There is no `.overdue` status to set, and completing it must clear the
        // condition without any status bookkeeping.
        delegation.completedAt = Date()
        XCTAssertFalse(delegation.isOverdue())
        XCTAssertEqual(delegation.daysLate(), 0)
    }

    func testCancelledDelegationIsNotOverdue() {
        let delegation = Delegation(what: "Dropped ask", dueDate: date(daysFromNow: -10))
        delegation.status = .cancelled
        XCTAssertFalse(delegation.isOverdue(), "A cancelled ask is not something anyone owes me.")
    }

    func testTaskWithoutDueDateIsNeverOverdue() {
        XCTAssertFalse(TaskItem(title: "Someday").isOverdue())
    }

    func testFollowUpRespectsSnooze() {
        let followUp = FollowUp(subject: "Chase Aaron", dueDate: date(daysFromNow: -1))
        XCTAssertTrue(followUp.isDue())

        followUp.snoozedUntil = date(daysFromNow: 2)
        XCTAssertFalse(followUp.isDue(), "Snoozing must suppress the signal without losing the original date.")
        XCTAssertNotNil(followUp.dueDate)
    }

    // MARK: Health override always expires

    func testHealthOverrideExpires() {
        let project = Project(name: "XPro Health Website")
        project.healthOverride = .onTrack
        project.healthOverrideExpiresAt = date(daysFromNow: 7)
        XCTAssertEqual(project.healthOverride, .onTrack)

        project.healthOverrideExpiresAt = date(daysFromNow: -1)
        XCTAssertNil(
            project.healthOverride,
            "An expired override must stop applying, or a stale 'it's fine' hides a real problem forever."
        )
    }

    func testClearingHealthOverrideClearsItsReason() {
        let project = Project(name: "Test")
        project.healthOverride = .atRisk
        project.healthOverrideReason = "Waiting on the landlord"
        project.healthOverride = nil
        XCTAssertTrue(project.healthOverrideReason.isEmpty)
        XCTAssertNil(project.healthOverrideExpiresAt)
    }

    func testElapsedFractionIsNilWithoutBothDates() {
        let project = Project(name: "No dates")
        XCTAssertNil(project.elapsedFraction, "Missing dates must read as 'cannot evaluate', not 'on track'.")

        project.startDate = date(daysFromNow: -10)
        project.targetDate = date(daysFromNow: 10)
        let fraction = try? XCTUnwrap(project.elapsedFraction)
        XCTAssertEqual(fraction ?? 0, 0.5, accuracy: 0.05)
    }

    // MARK: Enum storage survives unknown values

    func testUnknownRawValueFallsBackInsteadOfCrashing() {
        let task = TaskItem(title: "From a future build")
        task.statusRaw = "somethingAddedInV3"
        XCTAssertEqual(task.status, .inbox, "An older build must degrade, not crash, on a newer enum case.")
    }

    // MARK: Delimited lists

    func testDelimitedListRoundTrips() {
        let task = TaskItem(title: "Tagged")
        task.tags = ["ops", "finance", "ops"]
        XCTAssertEqual(task.tags, ["ops", "finance"], "Duplicates are dropped, order is kept.")
        XCTAssertTrue(DelimitedList.contains(task.tagsRaw, "ops"))
    }

    func testTokenMatchingDoesNotMatchPrefixes() {
        let raw = DelimitedList.encode(["operations"])
        XCTAssertFalse(
            DelimitedList.contains(raw, "ops"),
            "Whole-token matching is the point: 'ops' must not match 'operations'."
        )
    }

    func testEmptyListEncodesToEmptyString() {
        XCTAssertEqual(DelimitedList.encode([]), "")
        XCTAssertEqual(DelimitedList.encode(["", "   "]), "")
        XCTAssertEqual(DelimitedList.decode(""), [])
    }

    // MARK: Relationships

    func testProjectCompanyRelationshipIsBidirectional() throws {
        let context = try makeContext()
        let company = Company(name: "XPro Health")
        let project = Project(name: "Website", company: company)
        context.insert(company)
        context.insert(project)
        try context.save()

        XCTAssertEqual(project.company?.name, "XPro Health")
        XCTAssertEqual(company.projects.count, 1, "The inverse must be maintained without setting both sides.")
    }

    func testDeletingCompanyDoesNotDeleteItsProjects() throws {
        let context = try makeContext()
        let company = Company(name: "Doomed")
        let project = Project(name: "Survivor", company: company)
        context.insert(company)
        context.insert(project)
        try context.save()

        context.delete(company)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<Project>())
        XCTAssertEqual(remaining.count, 1, "Nullify, not cascade — a company must never take a year of projects with it.")
        XCTAssertNil(remaining.first?.company)
    }

    func testDeletingProjectCascadesToMilestones() throws {
        let context = try makeContext()
        let project = Project(name: "With milestones")
        let milestone = Milestone(title: "M1")
        milestone.project = project
        context.insert(project)
        context.insert(milestone)
        try context.save()

        context.delete(project)
        try context.save()

        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Milestone>()), 0)
    }
}
