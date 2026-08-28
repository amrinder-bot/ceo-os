import WidgetKit
import SwiftUI
import SwiftData
import CEOOSKit

@main
struct CEOOSWidgetBundle: WidgetBundle {
    var body: some Widget {
        FoundationWidget()
    }
}

/// Slice 1 widget.
///
/// It shows almost nothing, and that is the point: its job right now is to
/// prove that an extension can open the same SwiftData store as the app through
/// the App Group. That is the single Phase 0 assumption that is expensive to
/// discover is wrong after there are real records in the database.
///
/// The Top 3 / next meeting / attention widget replaces this once the Attention
/// Engine exists.
struct FoundationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CEOOSFoundation", provider: FoundationProvider()) { entry in
            FoundationWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("CEO OS")
        .description("Confirms the widget can read the CEO OS database.")
        .supportedFamilies([.systemSmall])
    }
}

struct FoundationEntry: TimelineEntry {
    let date: Date
    let companyCount: Int
    let projectCount: Int
    let problem: String?
}

struct FoundationProvider: TimelineProvider {

    func placeholder(in context: Context) -> FoundationEntry {
        FoundationEntry(date: .now, companyCount: 0, projectCount: 0, problem: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (FoundationEntry) -> Void) {
        completion(read())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FoundationEntry>) -> Void) {
        // Refresh hourly. Once the Attention Engine exists, the app reloads
        // timelines on change instead of the widget polling.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now
        completion(Timeline(entries: [read()], policy: .after(next)))
    }

    /// Opens the store read-only, without CloudKit. The widget displays what the
    /// app has already synced; it does not sync on its own.
    private func read() -> FoundationEntry {
        let result = ModelContainerFactory.make(role: .readOnlyExtension)
        if let warning = result.warnings.first {
            return FoundationEntry(date: .now, companyCount: 0, projectCount: 0, problem: warning)
        }
        do {
            let context = ModelContext(result.container)
            let companies = try context.fetchCount(FetchDescriptor<Company>())
            let projects = try context.fetchCount(FetchDescriptor<Project>())
            return FoundationEntry(date: .now, companyCount: companies, projectCount: projects, problem: nil)
        } catch {
            return FoundationEntry(date: .now, companyCount: 0, projectCount: 0, problem: error.localizedDescription)
        }
    }
}

struct FoundationWidgetView: View {
    let entry: FoundationEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CEO OS")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            if let problem = entry.problem {
                Text("Can't read the database")
                    .font(.subheadline.weight(.medium))
                Text(problem)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            } else {
                Text("\(entry.companyCount)")
                    .font(.system(size: 40, weight: .semibold, design: .rounded))
                Text(entry.companyCount == 1 ? "company" : "companies")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(entry.projectCount) projects")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
