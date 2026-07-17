//
//  AIView.swift
//  Reson
//

import SwiftUI
import SwiftData

struct AIView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var goalTitle = ""
    @State private var goalDescription = ""
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    @State private var isShowingSuccess = false
    @State private var errorMessage: String?

    private let taskTemplates = [
        "Define the outcome",
        "Break down the key milestones",
        "Complete the first action",
        "Review progress",
        "Wrap up and reflect"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    TextField("Goal title", text: $goalTitle)
                    TextField("Description (Optional)", text: $goalDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Timeline") {
                    DatePicker(
                        "Target date",
                        selection: $targetDate,
                        in: Date.now...,
                        displayedComponents: .date
                    )
                }

                Section {
                    Button("Create Plan", action: createPlan)
                        .frame(maxWidth: .infinity)
                        .disabled(goalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("AI")
            .alert("Plan Created", isPresented: $isShowingSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("A project and five tasks were created for your goal.")
            }
            .alert("Unable to Create Plan", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Please enter a goal title.")
            }
        }
    }

    private func createPlan() {
        let trimmedTitle = goalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a goal title."
            return
        }

        let project = ProjectItem(
            title: trimmedTitle,
            projectDescription: goalDescription,
            targetDate: targetDate
        )
        modelContext.insert(project)

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: .now)
        let endDate = calendar.startOfDay(for: targetDate)
        let interval = max(0, calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0)

        for (index, taskTitle) in taskTemplates.enumerated() {
            let offset = taskTemplates.count > 1
                ? (interval * index) / (taskTemplates.count - 1)
                : 0
            let dueDate = calendar.date(byAdding: .day, value: offset, to: startDate)

            modelContext.insert(
                TaskItem(
                    title: taskTitle,
                    dueDate: dueDate,
                    project: project
                )
            )
        }

        do {
            try modelContext.save()
            goalTitle = ""
            goalDescription = ""
            targetDate = calendar.date(byAdding: .month, value: 1, to: .now) ?? .now
            isShowingSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    AIView()
        .modelContainer(for: [ProjectItem.self, TaskItem.self], inMemory: true)
}
