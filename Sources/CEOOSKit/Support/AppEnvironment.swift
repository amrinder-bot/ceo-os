import Foundation

/// Identifiers that must agree across the app, the widget, the entitlements
/// files, and the CloudKit dashboard.
///
/// If you change the bundle identifier prefix, change it in exactly these
/// places: this file, `project.yml`, `Sources/CEOOS/Resources/CEOOS.entitlements`,
/// and `Sources/CEOOSWidgets/CEOOSWidgets.entitlements`.
public enum AppEnvironment {

    /// The App Group that holds the SwiftData store. The app, the widget, and
    /// (later) the intents extension all open the same file here.
    public static let appGroupIdentifier = "group.com.kambojventures.ceoos"

    /// The CloudKit container backing the private database.
    public static let cloudKitContainerIdentifier = "iCloud.com.kambojventures.ceoos"

    /// URL scheme for deep links: `ceoos://project/<uuid>`.
    public static let urlScheme = "ceoos"

    /// Background task identifiers. Both are declared in the app's Info.plist.
    public enum BackgroundTask {
        public static let refresh = "com.kambojventures.ceoos.refresh"
        public static let maintenance = "com.kambojventures.ceoos.maintenance"
    }

    /// The App Group container directory.
    ///
    /// Returns `nil` when the App Group is not configured — which in practice
    /// means the entitlement is missing or the provisioning profile does not
    /// carry it. Callers must handle that rather than force-unwrapping, because
    /// it is a real failure mode on a fresh machine and the error message
    /// should say so.
    public static var appGroupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
}
