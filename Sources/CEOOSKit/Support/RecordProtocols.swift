import Foundation

/// Every CEO OS record carries these.
///
/// `uuid` is the stable identity used by deep links, notification identifiers,
/// widget payloads, and cross-record references. It is deliberately *not*
/// `@Attribute(.unique)` — CloudKit does not support unique constraints, and a
/// schema that declares one fails at runtime rather than at compile time.
/// Uniqueness is enforced on write instead; see `CEOOSStore`.
public protocol CEOOSRecord: AnyObject {
    var uuid: UUID { get set }
    var createdAt: Date { get set }

    /// Team-readiness hook C1 (see Appendix C of the architecture document).
    /// Always the local user today. Present from schema v1 because adding an
    /// ownership column to a live CloudKit database means backfilling every
    /// record on every device, and CloudKit schema changes are additive-only.
    var ownerUserID: String { get set }
    var createdByUserID: String { get set }
}

/// Records that are soft-deleted rather than destroyed.
///
/// Deleting sets `archivedAt`; a hard purge happens locally after a grace
/// period. This is what stops a CloudKit sync race from permanently destroying
/// a project — see Section 6, conflict rule 5.
public protocol Archivable: AnyObject {
    var archivedAt: Date? { get set }
}

extension Archivable {
    public var isArchived: Bool { archivedAt != nil }
}

/// Records whose visibility will matter if CEO OS ever has more than one user.
/// Team-readiness hook C5. Everything defaults to `privateToMe`.
public protocol VisibilityScoped: AnyObject {
    var visibilityRaw: String { get set }
}

extension VisibilityScoped {
    public var visibility: Visibility {
        get { Visibility(rawValue: visibilityRaw) ?? .privateToMe }
        set { visibilityRaw = newValue.rawValue }
    }
}

/// Records that can be completed, where completion is monotonic.
///
/// Section 6, conflict rule 4: on a CloudKit merge any non-nil `completedAt`
/// beats `nil`. Marking something done must never be undone by a stale device.
public protocol Completable: AnyObject {
    var completedAt: Date? { get set }
}

extension Completable {
    public var isCompleted: Bool { completedAt != nil }
}
