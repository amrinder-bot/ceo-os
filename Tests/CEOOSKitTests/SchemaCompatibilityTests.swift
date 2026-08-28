import XCTest
import SwiftData
@testable import CEOOSKit

/// Guards the four rules in `SchemaV1`'s documentation.
///
/// SwiftData's CloudKit mirroring fails at *runtime*, and often only on a real
/// device signed into iCloud — which is the worst possible place to find out.
/// These tests move that failure into the build.
final class SchemaCompatibilityTests: XCTestCase {

    private func makeSchema() -> Schema {
        Schema(versionedSchema: SchemaV1.self)
    }

    /// The load-bearing test. Building a container validates the whole object
    /// graph: every relationship resolves, every inverse pairs up, no property
    /// name collides. Almost every mistake in the model surfaces here.
    func testInMemoryContainerBuilds() throws {
        let schema = makeSchema()
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        XCTAssertNoThrow(try ModelContainer(for: schema, configurations: config))
    }

    func testSchemaContainsEveryModel() {
        let schema = makeSchema()
        XCTAssertEqual(
            schema.entities.count,
            SchemaV1.models.count,
            "An entity in SchemaV1.models did not make it into the schema."
        )
        XCTAssertFalse(schema.entities.isEmpty)
    }

    func testVersionIsPinned() {
        XCTAssertEqual(SchemaV1.versionIdentifier, Schema.Version(1, 0, 0))
        XCTAssertEqual(CEOOSMigrationPlan.schemas.count, 1)
    }

    // MARK: - CloudKit rules
    //
    // These three read the schema's own metadata. If a property name below does
    // not exist in your SDK, delete that single assertion rather than working
    // around it — `testInMemoryContainerBuilds` above is the guarantee that
    // actually matters, and these are an early-warning layer on top of it.

    /// Rule 1: every attribute is optional or carries a default.
    func testEveryAttributeIsOptionalOrDefaulted() {
        for entity in makeSchema().entities {
            for attribute in entity.attributes {
                let ok = attribute.isOptional || attribute.defaultValue != nil
                XCTAssertTrue(
                    ok,
                    "\(entity.name).\(attribute.name) is neither optional nor defaulted. "
                    + "CloudKit mirroring rejects the store at runtime when this is true."
                )
            }
        }
    }

    /// Rule 2: no unique constraints. CloudKit has no way to enforce one, and a
    /// schema that declares it fails to load. Uniqueness is an application
    /// concern here — see `CEOOSRecord.uuid`.
    func testNoUniqueAttributes() {
        for entity in makeSchema().entities {
            for attribute in entity.attributes {
                XCTAssertFalse(
                    attribute.isUnique,
                    "\(entity.name).\(attribute.name) is marked unique. CloudKit does not support unique constraints."
                )
            }
        }
    }

    /// Rule 3: every relationship has an inverse.
    func testEveryRelationshipHasAnInverse() {
        for entity in makeSchema().entities {
            for relationship in entity.relationships {
                XCTAssertNotNil(
                    relationship.inverseName,
                    "\(entity.name).\(relationship.name) has no inverse. CloudKit requires one on every relationship."
                )
            }
        }
    }
}
