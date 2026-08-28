import Foundation
import SwiftData
import OSLog

/// Builds the SwiftData container, and degrades honestly when it cannot.
///
/// The store lives in the App Group so the widget and (later) the intents
/// extension can read it. That was decided in commit one on purpose: moving a
/// live, CloudKit-synced store into an App Group afterwards is a file migration
/// on a database you depend on daily.
///
/// Nothing here ever calls `fatalError`. An app that crashes on launch because
/// the store failed cannot tell you *why* it failed — and "iCloud is signed
/// out" is a normal Tuesday, not a programming error. The container degrades
/// through three levels and reports which one it landed on so the Diagnostics
/// screen can say something true.
public enum ModelContainerFactory {

    private static let log = Logger(subsystem: "com.kambojventures.ceoos", category: "store")

    public enum Role {
        /// The app: read/write, CloudKit mirroring on.
        case app
        /// A widget or extension: reads what the app has already synced, and
        /// never syncs on its own. Extensions get short, unpredictable
        /// lifetimes, and a half-finished CloudKit import in a widget refresh
        /// is a bad trade for data that is at most a few minutes stale.
        case readOnlyExtension
    }

    /// How the store actually came up. Surfaced in Diagnostics rather than
    /// hidden, because "my iPad isn't updating" needs an answer.
    public enum Mode: String, Sendable {
        case cloudKit = "iCloud sync on"
        case localOnly = "On this device only"
        case inMemory = "Temporary — nothing is being saved"
    }

    public struct Result {
        public let container: ModelContainer
        public let mode: Mode
        /// The store file, when there is one.
        public let storeURL: URL?
        /// Non-fatal problems, in the order they happened. Shown verbatim in
        /// Diagnostics — a real error message beats a friendly vague one when
        /// something is actually wrong.
        public let warnings: [String]
    }

    public static func make(role: Role) -> Result {
        var warnings: [String] = []

        // If the App Group is not reachable, SwiftData will still open a store —
        // just not a shared one — and the widget would then silently read an
        // empty database. Say so rather than letting that look like "no data".
        if AppEnvironment.appGroupContainerURL == nil {
            warnings.append(
                "App Group '\(AppEnvironment.appGroupIdentifier)' is not available, so the widget "
                + "will not see this data. Check that the App Groups capability is enabled on both "
                + "targets and that the identifier matches."
            )
        }

        let schema = Schema(versionedSchema: SchemaV1.self)

        // 1. CloudKit-backed, in the App Group. The intended path.
        if role == .app {
            do {
                let config = makeConfiguration(schema: schema, cloudKit: true)
                let container = try ModelContainer(for: schema, migrationPlan: CEOOSMigrationPlan.self, configurations: config)
                log.info("Store opened with CloudKit mirroring")
                return Result(container: container, mode: .cloudKit, storeURL: storeURL(of: container), warnings: warnings)
            } catch {
                warnings.append(
                    "iCloud sync is off because the store could not be opened with CloudKit: \(error.localizedDescription) "
                    + "Your data is safe on this device and will sync once this is resolved."
                )
                log.error("CloudKit container failed: \(String(describing: error))")
            }
        }

        // 2. Local only. Correct for extensions, and the fallback for the app
        //    when iCloud is unavailable — signed out, out of storage, or
        //    restricted. Everything keeps working; it just does not sync.
        do {
            let config = makeConfiguration(schema: schema, cloudKit: false)
            let container = try ModelContainer(for: schema, migrationPlan: CEOOSMigrationPlan.self, configurations: config)
            return Result(container: container, mode: .localOnly, storeURL: storeURL(of: container), warnings: warnings)
        } catch {
            warnings.append("The database could not be opened: \(error.localizedDescription)")
            log.fault("Local container failed: \(String(describing: error))")
        }

        // 3. In memory. The app launches, shows the warnings, and lets you get
        //    to Diagnostics. Nothing is written to disk in this state, and the
        //    UI says so plainly rather than pretending to save.
        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: config)
            return Result(container: container, mode: .inMemory, storeURL: nil, warnings: warnings)
        } catch {
            // Nothing is left to try. An empty schema always builds, so this
            // keeps the app launchable and the error visible.
            let container = try! ModelContainer(
                for: Schema([]),
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            return Result(
                container: container,
                mode: .inMemory,
                storeURL: nil,
                warnings: warnings + ["The data model itself failed to load: \(error.localizedDescription)"]
            )
        }
    }

    /// The App Group is requested by identifier rather than by building a file
    /// URL by hand. SwiftData then owns where the file sits inside the group,
    /// which is one less thing to get subtly wrong across three targets.
    /// Where the store actually landed, straight from the container rather
    /// than assumed. Diagnostics shows this, and an assumed path that differs
    /// from the real one is worse than no path at all.
    private static func storeURL(of container: ModelContainer) -> URL? {
        container.configurations.first?.url
    }

    private static func makeConfiguration(schema: Schema, cloudKit: Bool) -> ModelConfiguration {
        let cloudKitDatabase: ModelConfiguration.CloudKitDatabase =
            cloudKit ? .private(AppEnvironment.cloudKitContainerIdentifier) : .none

        return ModelConfiguration(
            "CEOOS",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier(AppEnvironment.appGroupIdentifier),
            cloudKitDatabase: cloudKitDatabase
        )
    }
}
