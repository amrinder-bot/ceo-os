import Foundation

/// Storage for small string lists (tags, evidence IDs, selected calendar IDs)
/// inside a single `String` attribute.
///
/// Why not `[String]`: SwiftData stores a primitive array as an opaque binary
/// blob, which `#Predicate` cannot look inside. Every "show me everything tagged
/// `ops`" query would have to load and filter in memory. Encoding the list into
/// one delimited string keeps it queryable with a plain `contains`, and keeps
/// the CloudKit record a simple string field.
///
/// The encoding puts a separator on both ends — `␟ops␟finance␟` — so that
/// searching for `␟ops␟` matches the whole token and never a prefix of another
/// tag. Use `token(_:)` to build the needle; never hand-write the separator.
public enum DelimitedList {

    /// ASCII 0x1F UNIT SEPARATOR. Chosen because it cannot occur in user text
    /// typed on a keyboard, so no tag can ever break the encoding.
    public static let separator = "\u{001F}"

    /// Encodes a list. Values are trimmed; empties and duplicates are dropped.
    /// Order is preserved.
    public static func encode(_ values: [String]) -> String {
        var seen = Set<String>()
        let cleaned = values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { seen.insert($0.lowercased()).inserted }
        guard !cleaned.isEmpty else { return "" }
        return separator + cleaned.joined(separator: separator) + separator
    }

    /// Decodes a stored value back into a list.
    public static func decode(_ raw: String) -> [String] {
        raw.components(separatedBy: separator).filter { !$0.isEmpty }
    }

    /// The exact substring to search for when matching one whole value.
    ///
    ///     let needle = DelimitedList.token("ops")
    ///     #Predicate<TaskItem> { $0.tagsRaw.contains(needle) }
    public static func token(_ value: String) -> String {
        separator + value.trimmingCharacters(in: .whitespacesAndNewlines) + separator
    }

    /// Whether an encoded list contains a value.
    public static func contains(_ raw: String, _ value: String) -> Bool {
        raw.contains(token(value))
    }
}
