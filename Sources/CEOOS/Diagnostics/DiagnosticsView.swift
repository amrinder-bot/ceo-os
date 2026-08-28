import SwiftUI
import SwiftData
import CloudKit
import CEOOSKit

/// What the app knows about its own storage.
///
/// This screen exists from commit one because the questions it answers — is
/// iCloud actually on, is the widget reading the same database, did that write
/// land — are unanswerable by staring at the UI, and guessing at them wastes
/// more time than the screen costs. It becomes Settings → Diagnostics later.
struct DiagnosticsView: View {

    let storeResult: ModelContainerFactory.Result

    @Environment(\.modelContext) private var context
    @Query(sort: \Company.sortOrder) private var companies: [Company]
    @Query private var projects: [Project]
    @Query private var tasks: [TaskItem]
    @Query private var people: [Person]
    @Query private var rules: [NotificationRule]

    @State private var accountStatus = "Checking…"
    @State private var lastAction = ""

    var body: some View {
        List {
            Section("Storage") {
                LabeledContent("Mode", value: storeResult.mode.rawValue)
                LabeledContent("iCloud account", value: accountStatus)
                LabeledContent("Shared with widget", value: AppEnvironment.appGroupContainerURL != nil ? "Yes" : "No")
                if let url = storeResult.storeURL {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Store file").font(.caption).foregroundStyle(.secondary)
                        Text(url.path)
                            .font(.system(.caption2, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
            }

            if !storeResult.warnings.isEmpty {
                Section("Problems") {
                    ForEach(Array(storeResult.warnings.enumerated()), id: \.offset) { _, warning in
                        Text(warning)
                            .font(.callout)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Section("Records") {
                LabeledContent("Companies", value: "\(companies.count)")
                LabeledContent("People", value: "\(people.count)")
                LabeledContent("Projects", value: "\(projects.count)")
                LabeledContent("Tasks", value: "\(tasks.count)")
                LabeledContent("Notification rules", value: "\(rules.count)")
            }

            Section {
                ForEach(companies) { company in
                    HStack {
                        Image(systemName: company.symbolName)
                            .foregroundStyle(Color(hex: company.colorHex))
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text(company.name)
                            if !company.synonyms.isEmpty {
                                Text(company.synonyms.joined(separator: " · "))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            } header: {
                Text("Companies")
            } footer: {
                Text("Seeded on first launch and fully editable. Nothing in the code refers to a company by name.")
            }

            Section {
                Button("Add a round-trip test project") { addTestProject() }
                Button("Delete test projects", role: .destructive) { deleteTestProjects() }
                if !lastAction.isEmpty {
                    Text(lastAction).font(.caption).foregroundStyle(.secondary)
                }
            } header: {
                Text("Sync check")
            } footer: {
                Text("Add one here, then open CEO OS on another device signed into the same iCloud account. If it appears within a minute or so, CloudKit mirroring is working.")
            }
        }
        .navigationTitle("Diagnostics")
        .task { await loadAccountStatus() }
    }

    private func addTestProject() {
        let project = Project(name: "Sync test \(Date().formatted(date: .omitted, time: .standard))")
        project.company = companies.first
        project.detail = "Created from Diagnostics to verify CloudKit round-trip."
        context.insert(project)
        save("Added.")
    }

    private func deleteTestProjects() {
        let doomed = projects.filter { $0.name.hasPrefix("Sync test ") }
        doomed.forEach(context.delete)
        save("Deleted \(doomed.count).")
    }

    private func save(_ message: String) {
        do {
            try context.save()
            lastAction = message
        } catch {
            lastAction = "Save failed: \(error.localizedDescription)"
        }
    }

    private func loadAccountStatus() async {
        do {
            let status = try await CKContainer(identifier: AppEnvironment.cloudKitContainerIdentifier).accountStatus()
            accountStatus = switch status {
            case .available: "Signed in"
            case .noAccount: "Not signed in to iCloud"
            case .restricted: "Restricted"
            case .couldNotDetermine: "Unknown"
            case .temporarilyUnavailable: "Temporarily unavailable"
            @unknown default: "Unknown"
            }
        } catch {
            accountStatus = error.localizedDescription
        }
    }
}

extension Color {
    /// Parses the `#RRGGBB` strings stored on Company. Falls back to grey on
    /// anything unexpected rather than trapping — colour is not worth a crash.
    init(hex: String) {
        let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else {
            self = .gray
            return
        }
        self = Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
