//
//  ProgressView.swift
//  Reson
//

import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query private var projects: [ProjectItem]
    @Query private var tasks: [TaskItem]

    private var activeGoals: [ProjectItem] {
        projects.filter { !$0.isArchived }
    }

    private var completedTaskCount: Int {
        tasks.filter(\.isCompleted).count
    }

    private var incompleteTaskCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }

    private var rescheduledTaskCount: Int {
        tasks.filter(\.wasSkipped).count
    }

    private var sortedGoals: [ProjectItem] {
        projects.sorted { lhs, rhs in
            if lhs.isArchived != rhs.isArchived {
                return !lhs.isArchived
            }

            let lhsDate = lhs.targetDate ?? .distantFuture
            let rhsDate = rhs.targetDate ?? .distantFuture
            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            }

            return lhs.createdAt < rhs.createdAt
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No Goals Yet",
                        systemImage: "chart.bar",
                        description: Text("Create a goal to see your progress here.")
                    )
                } else {
                    List {
                        Section("Overview") {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 12
                            ) {
                                ProgressStatistic(title: "Total Goals", value: projects.count, systemImage: "target")
                                ProgressStatistic(title: "Active Goals", value: activeGoals.count, systemImage: "flag")
                                ProgressStatistic(title: "Completed", value: completedTaskCount, systemImage: "checkmark.circle")
                                ProgressStatistic(title: "Incomplete", value: incompleteTaskCount, systemImage: "circle")
                                ProgressStatistic(title: "Rescheduled", value: rescheduledTaskCount, systemImage: "arrow.triangle.2.circlepath")
                            }
                            .padding(.vertical, 4)
                        }

                        Section("Goals") {
                            ForEach(sortedGoals) { project in
                                GoalProgressRow(
                                    project: project,
                                    tasks: tasks.filter { $0.project?.id == project.id }
                                )
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Progress")
        }
    }
}

private struct ProgressStatistic: View {
    let title: String
    let value: Int
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value, format: .number)
                .font(.title2.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct GoalProgressRow: View {
    let project: ProjectItem
    let tasks: [TaskItem]

    private var completedTaskCount: Int {
        tasks.filter(\.isCompleted).count
    }

    private var rescheduledTaskCount: Int {
        tasks.filter(\.wasSkipped).count
    }

    private var progress: Double {
        guard !tasks.isEmpty else { return 0 }
        return min(1, max(0, Double(completedTaskCount) / Double(tasks.count)))
    }

    private var progressPercentage: Int {
        Int((progress * 100).rounded())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(project.title)
                    .font(.headline)

                Spacer()

                Text("\(progressPercentage)%")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if let targetDate = project.targetDate {
                Label(
                    targetDate.formatted(date: .abbreviated, time: .omitted),
                    systemImage: "calendar"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            } else {
                Label("No target date", systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            SwiftUI.ProgressView(value: progress)
                .tint(.accentColor)

            HStack {
                Text("\(completedTaskCount) of \(tasks.count) tasks completed")

                Spacer()

                Label("\(rescheduledTaskCount) rescheduled", systemImage: "arrow.triangle.2.circlepath")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: [ProjectItem.self, TaskItem.self], inMemory: true)
}
