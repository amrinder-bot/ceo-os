import SwiftUI
import CEOOSKit

/// Slice 1 root.
///
/// The five-tab shell arrives in the next slice. Until the data layer is
/// verified on real hardware, the only thing worth showing is whether the
/// foundation actually works — so the app opens straight onto Diagnostics,
/// which is a permanent screen (Settings → Diagnostics), not a placeholder.
struct RootView: View {
    let storeResult: ModelContainerFactory.Result

    var body: some View {
        NavigationStack {
            DiagnosticsView(storeResult: storeResult)
        }
    }
}
