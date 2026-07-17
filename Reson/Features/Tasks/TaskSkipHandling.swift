//
//  TaskSkipHandling.swift
//  Reson
//

import SwiftUI

enum TaskSkipReason: String, CaseIterable, Identifiable {
    case noTime = "No time"
    case tooDifficult = "Too difficult"
    case lowEnergy = "Low energy"
    case notRelevantAnymore = "Not relevant anymore"
    case other = "Other"

    var id: String { rawValue }
    var title: String { rawValue }
}

struct TaskSkipSheet: View {
    @Environment(\.dismiss) private var dismiss
    let taskTitle: String
    let onConfirm: (TaskSkipReason) -> Void
    @State private var selectedReason: TaskSkipReason = .noTime

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text(taskTitle)
                        .font(.headline)
                } header: {
                    Text("Skip task")
                }

                Section("Reason") {
                    Picker("Reason", selection: $selectedReason) {
                        ForEach(TaskSkipReason.allCases) { reason in
                            Text(reason.title).tag(reason)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Skip Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Skip") {
                        onConfirm(selectedReason)
                        dismiss()
                    }
                }
            }
        }
    }
}

enum TaskPlanAdapter {
    static func skip(
        _ task: TaskItem,
        reason: TaskSkipReason,
        among tasks: [TaskItem],
        calendar: Calendar = .current
    ) {
        task.wasSkipped = true
        task.skipReason = reason.rawValue
        task.dueDate = rescheduledDate(for: task, among: tasks, calendar: calendar)
    }

    private static func rescheduledDate(
        for task: TaskItem,
        among tasks: [TaskItem],
        calendar: Calendar
    ) -> Date {
        let today = calendar.startOfDay(for: .now)
        let nextDay = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let targetDay = task.project?.targetDate.map { calendar.startOfDay(for: $0) }
        let scheduledDay: Date

        if let targetDay, nextDay > targetDay {
            scheduledDay = targetDay
        } else {
            scheduledDay = nextDay
        }

        guard let projectID = task.project?.id else {
            return scheduledDay
        }

        let sameDayProjectTasks = tasks.filter { otherTask in
            otherTask.id != task.id
                && !otherTask.isCompleted
                && otherTask.project?.id == projectID
                && otherTask.dueDate.map { calendar.isDate($0, inSameDayAs: scheduledDay) } == true
        }

        guard let latestTaskDate = sameDayProjectTasks.compactMap(\.dueDate).max() else {
            return scheduledDay
        }

        let nextSlot = calendar.date(byAdding: .minute, value: 1, to: latestTaskDate)
        if let nextSlot, calendar.isDate(nextSlot, inSameDayAs: scheduledDay) {
            return nextSlot
        }

        return calendar.date(bySettingHour: 23, minute: 59, second: 0, of: scheduledDay) ?? scheduledDay
    }
}
