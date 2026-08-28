import Foundation
import SwiftData

/// Schema version 1.
///
/// Versioned from the very first commit even though there is nothing to migrate
/// yet. Adding versioning after real data exists is the hard version of this
/// job, and CloudKit makes it harder still: in production a CloudKit schema can
/// only be *added to* — you cannot delete a field or change its type. So v1 is
/// deliberately generous. An unused optional field costs nothing; a missing one
/// costs a migration.
///
/// ## The four rules this schema obeys
///
/// SwiftData's CloudKit mirroring fails at *runtime*, not compile time, when
/// these are broken — which is why `SchemaCompatibilityTests` exists.
///
/// 1. Every attribute is optional or has a default value.
/// 2. No `@Attribute(.unique)` anywhere. Uniqueness is enforced on write.
/// 3. Every to-one relationship is optional, and every relationship has an
///    inverse declared on exactly one side.
/// 4. No custom merge policy exists, so conflicts are last-writer-wins per
///    record. The schema is shaped to make that safe rather than to fight it —
///    see the notes on append-only records in `ProjectUpdate` and `CaptureItem`.
public enum SchemaV1: VersionedSchema {

    public static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    public static var models: [any PersistentModel.Type] {
        [
            // Settings
            UserProfile.self,
            NotificationRule.self,
            IntegrationAccount.self,

            // Organisation
            Company.self,
            Person.self,
            Goal.self,

            // Work
            Project.self,
            Milestone.self,
            ProjectUpdate.self,
            TaskItem.self,
            Delegation.self,
            FollowUp.self,

            // Thinking
            Idea.self,
            NoteItem.self,
            Decision.self,

            // Time
            Meeting.self,
            CalendarEventLink.self,
            ExternalReminderLink.self,

            // System
            CaptureItem.self,
            AttentionSignalRecord.self,
            DailyPlan.self,
            PriorityItem.self,
            StatusHistory.self,
            Attachment.self,
        ]
    }
}

/// Migration plan.
///
/// Empty today by definition — there is only one version. It exists now so that
/// v2 is a two-line change instead of an archaeology project.
public enum CEOOSMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] { [SchemaV1.self] }
    public static var stages: [MigrationStage] { [] }
}
