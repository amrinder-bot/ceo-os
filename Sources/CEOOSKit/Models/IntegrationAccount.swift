import Foundation
import SwiftData

/// A connected third-party account.
///
/// **No secret ever lives in this record.** `keychainAccount` is a lookup key
/// for the Keychain, not a token. Tokens are stored with
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` and are deliberately
/// excluded from iCloud Keychain sync, so each device authenticates on its own:
/// a synced OAuth token is both a credential-spraying risk and a refresh race.
///
/// Unused under decision D2 — Google Calendar is read through EventKit and there
/// is nothing to authenticate. The entity exists in schema v1 so that adding an
/// API integration later is additive rather than a CloudKit migration.
@Model
public final class IntegrationAccount: CEOOSRecord {

    public var uuid: UUID = UUID()
    public var createdAt: Date = Date()
    public var ownerUserID: String = ""
    public var createdByUserID: String = ""

    public var provider: String = ""
    public var accountEmail: String = ""
    /// Keychain account name. A reference. Never a credential.
    public var keychainAccount: String = ""
    public var grantedScopesRaw: String = ""
    public var grantedScopes: [String] {
        get { DelimitedList.decode(grantedScopesRaw) }
        set { grantedScopesRaw = DelimitedList.encode(newValue) }
    }

    public var connectedAt: Date?
    public var status: String = "disconnected"
    public var selectedCalendarIDsRaw: String = ""
    public var selectedCalendarIDs: [String] {
        get { DelimitedList.decode(selectedCalendarIDsRaw) }
        set { selectedCalendarIDsRaw = DelimitedList.encode(newValue) }
    }

    public var syncTokensJSON: String = ""
    public var lastSyncAt: Date?
    public var lastError: String = ""

    public init(provider: String, accountEmail: String = "") {
        self.provider = provider
        self.accountEmail = accountEmail
    }
}
