import SwiftUI
import SwiftData
import CEOOSKit

@main
struct CEOOSApp: App {

    /// Built once, at launch, and never rebuilt. The result carries how the
    /// store actually came up so the UI can tell the truth about sync instead
    /// of assuming it worked.
    private let store: ModelContainerFactory.Result

    init() {
        store = ModelContainerFactory.make(role: .app)
    }

    var body: some Scene {
        WindowGroup {
            RootView(storeResult: store)
                .task { seed() }
        }
        .modelContainer(store.container)
    }

    /// Seeding runs on the main context because it writes a handful of records
    /// exactly once. Background work arrives with the first real service.
    private func seed() {
        do {
            try FirstRunSeeder.seedIfNeeded(in: store.container.mainContext)
        } catch {
            // Non-fatal by design: an app that will not open because it could
            // not write a default settings record is worse than one that opens
            // and says so.
            print("[CEOOS] Seeding failed: \(error)")
        }
    }
}
