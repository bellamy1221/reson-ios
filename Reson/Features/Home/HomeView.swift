//
//  HomeView.swift
//  Reson
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var tasks: [TaskItem]
    @State private var taskToSkip: TaskItem?
    @State private var isShowingPlanUpdated = false

    private var scheduledTasks: [TaskItem] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? .distantFuture

        return tasks
            .filter { task in
                !task.isCompleted && (task.dueDate ?? .distantFuture) < startOfTomorrow
            }
            .sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
    }

    private var nextAction: TaskItem? {
        scheduledTasks.first
    }

    private var remainingTasks: [TaskItem] {
        Array(scheduledTasks.dropFirst())
    }

    var body: some View {
        NavigationStack {
            Group {
                if let nextAction {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Next Action")
                                .font(.headline)

                            TodayTaskRow(task: nextAction, isHighlighted: true) {
                                taskToSkip = nextAction
                            }

                            if !remainingTasks.isEmpty {
                                Text("Remaining Today")
                                    .font(.headline)

                                LazyVStack(spacing: 10) {
                                    ForEach(remainingTasks) { task in
                                        TodayTaskRow(task: task) {
                                            taskToSkip = task
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "No Tasks Today",
                        systemImage: "sun.max",
                        description: Text("You have no incomplete tasks due today or overdue.")
                    )
                }
            }
            .navigationTitle("Today")
            .sheet(item: $taskToSkip) { task in
                TaskSkipSheet(taskTitle: task.title) { reason in
                    skip(task, for: reason)
                }
            }
            .overlay(alignment: .bottom) {
                if isShowingPlanUpdated {
                    Text("Plan updated")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.regularMaterial, in: Capsule())
                        .padding(.bottom, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
    }

    private func skip(_ task: TaskItem, for reason: TaskSkipReason) {
        TaskPlanAdapter.skip(task, reason: reason, among: tasks)
        try? modelContext.save()
        showPlanUpdatedMessage()
    }

    private func showPlanUpdatedMessage() {
        withAnimation {
            isShowingPlanUpdated = true
        }

        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation {
                isShowingPlanUpdated = false
            }
        }
    }
}

private struct TodayTaskRow: View {
    let task: TaskItem
    var isHighlighted = false
    let onSkip: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                task.isCompleted.toggle()
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(task.title)
                            .font(isHighlighted ? .headline : .body)
                            .foregroundStyle(.primary)

                        Label(task.project?.title ?? "No Goal", systemImage: "target")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let dueDate = task.dueDate {
                            Label(
                                dueDate.formatted(date: .abbreviated, time: .shortened),
                                systemImage: "calendar"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        if task.wasSkipped {
                            Text("Rescheduled")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.orange)
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button("Skip", action: onSkip)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .padding(isHighlighted ? 16 : 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isHighlighted ? Color.accentColor.opacity(0.12) : Color.secondary.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [TaskItem.self, ProjectItem.self], inMemory: true)
}
