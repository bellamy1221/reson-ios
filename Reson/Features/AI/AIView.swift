//
//  AIView.swift
//  Reson
//

import SwiftUI
import SwiftData

struct AIView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep = 1
    @State private var goalTitle = ""
    @State private var goalDescription = ""
    @State private var targetDate = Calendar.current.date(byAdding: .month, value: 1, to: .now) ?? .now
    @State private var availableMinutes = 30
    @State private var workingDays: Set<Int> = Set(2...6)
    @State private var previewTasks: [PreviewTask] = []
    @State private var isShowingPlanPreview = false
    @State private var isShowingSuccess = false
    @State private var errorMessage: String?

    private let calendar = Calendar.current
    private let totalSteps = 5

    private var trimmedTitle: String {
        goalTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var minimumTargetDate: Date {
        calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: .now)) ?? .now
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SwiftUI.ProgressView(value: Double(currentStep), total: Double(totalSteps))

                    Text("Step \(currentStep) of \(totalSteps)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                stepContent

                Section {
                    HStack {
                        if currentStep > 1 {
                            Button("Back") {
                                currentStep -= 1
                            }
                        }

                        Spacer()

                        Button(currentStep == totalSteps ? "Create Goal" : "Continue") {
                            advance()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle("Coach")
            .navigationDestination(isPresented: $isShowingPlanPreview) {
                PlanPreviewView(
                    goalTitle: trimmedTitle,
                    targetDate: targetDate,
                    availableMinutes: availableMinutes,
                    workingDayTitles: selectedWorkingDayTitles,
                    tasks: $previewTasks,
                    createGoal: persistPreviewedPlan
                )
            }
            .alert("Goal Created", isPresented: $isShowingSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your goal and seven scheduled tasks are ready.")
            }
            .alert("Unable to Create Goal", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Please review your goal details.")
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 1:
            Section("Goal") {
                TextField("Goal title", text: $goalTitle)
                TextField("Description (Optional)", text: $goalDescription, axis: .vertical)
                    .lineLimit(3...6)
            }
        case 2:
            Section("Target date") {
                DatePicker(
                    "Complete by",
                    selection: $targetDate,
                    in: minimumTargetDate...,
                    displayedComponents: .date
                )
            }
        case 3:
            Section("Daily availability") {
                Stepper(value: $availableMinutes, in: 15...480, step: 15) {
                    Text("\(availableMinutes) minutes per day")
                }
            }
        case 4:
            Section("Preferred working days") {
                ForEach(Weekday.allCases) { day in
                    Toggle(day.title, isOn: workingDayBinding(for: day))
                }
            }
        default:
            Section("Goal") {
                LabeledContent("Title", value: trimmedTitle)

                if !goalDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    LabeledContent("Description", value: goalDescription)
                }
            }

            Section("Plan") {
                LabeledContent("Target date") {
                    Text(targetDate, format: .dateTime.month().day().year())
                }
                LabeledContent("Available time", value: "\(availableMinutes) min/day")
                LabeledContent("Working days", value: selectedWorkingDayTitles)
                LabeledContent("Tasks", value: "7")
            }
        }
    }

    private var selectedWorkingDayTitles: String {
        Weekday.allCases
            .filter { workingDays.contains($0.calendarWeekday) }
            .map(\.shortTitle)
            .joined(separator: ", ")
    }

    private func workingDayBinding(for day: Weekday) -> Binding<Bool> {
        Binding(
            get: { workingDays.contains(day.calendarWeekday) },
            set: { isSelected in
                if isSelected {
                    workingDays.insert(day.calendarWeekday)
                } else {
                    workingDays.remove(day.calendarWeekday)
                }
            }
        )
    }

    private func advance() {
        guard validateCurrentStep() else { return }

        if currentStep == totalSteps {
                            generatePlanPreview()
        } else {
            currentStep += 1
        }
    }

    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case 1 where trimmedTitle.isEmpty:
            errorMessage = "Please enter a goal title."
        case 2 where calendar.startOfDay(for: targetDate) <= calendar.startOfDay(for: .now):
            errorMessage = "Please choose a target date in the future."
        case 3 where availableMinutes < 15:
            errorMessage = "Please allow at least 15 minutes per day."
        case 4 where workingDays.isEmpty:
            errorMessage = "Please select at least one working day."
        default:
            return true
        }

        return false
    }

    private func generatePlanPreview() {
        guard validateAllSteps() else { return }

        let plan = LocalGoalPlan(title: trimmedTitle, availableMinutes: availableMinutes)
        let dueDates = scheduledDates(for: plan.steps.count)

        guard dueDates.count == plan.steps.count else {
            errorMessage = "No selected working days are available before the target date."
            return
        }

        previewTasks = []
        for (step, dueDate) in zip(plan.steps, dueDates) {
            previewTasks.append(PreviewTask(title: step.title, dueDate: dueDate))
        }

        isShowingPlanPreview = true
    }

    private func persistPreviewedPlan(_ tasks: [PreviewTask]) -> String? {
        guard let validationMessage = previewValidationMessage(for: tasks) else {
            let project = ProjectItem(
                title: trimmedTitle,
                projectDescription: goalDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                targetDate: targetDate
            )
            modelContext.insert(project)

            for task in tasks {
                modelContext.insert(TaskItem(title: task.title, dueDate: task.dueDate, project: project))
            }

            do {
                try modelContext.save()
                isShowingPlanPreview = false
                resetFlow()
                isShowingSuccess = true
                return nil
            } catch {
                return error.localizedDescription
            }
        }

        return validationMessage
    }

    private func previewValidationMessage(for tasks: [PreviewTask]) -> String? {
        guard !tasks.isEmpty else {
            return "Add at least one task before creating the goal."
        }

        guard tasks.allSatisfy({ !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            return "Every task needs a title."
        }

        let targetDay = calendar.startOfDay(for: targetDate)
        guard tasks.allSatisfy({ calendar.startOfDay(for: $0.dueDate) <= targetDay }) else {
            return "Every task must be due on or before the target date."
        }

        guard zip(tasks, tasks.dropFirst()).allSatisfy({ first, second in
            calendar.startOfDay(for: first.dueDate) <= calendar.startOfDay(for: second.dueDate)
        }) else {
            return "Arrange tasks in chronological due-date order before creating the goal."
        }

        return nil
    }

    private func validateAllSteps() -> Bool {
        let savedStep = currentStep
        defer { currentStep = savedStep }

        for step in 1...4 {
            currentStep = step
            guard validateCurrentStep() else { return false }
        }

        return true
    }

    private func scheduledDates(for taskCount: Int) -> [Date] {
        let startDate = calendar.startOfDay(for: .now)
        let endDate = calendar.startOfDay(for: targetDate)
        var eligibleDates: [Date] = []
        var date = startDate

        while date <= endDate {
            if workingDays.contains(calendar.component(.weekday, from: date)) {
                eligibleDates.append(date)
            }
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? endDate.addingTimeInterval(1)
        }

        guard !eligibleDates.isEmpty, taskCount > 0 else { return [] }

        return (0..<taskCount).map { index in
            let dateIndex = taskCount == 1 ? 0 : (eligibleDates.count - 1) * index / (taskCount - 1)
            return eligibleDates[dateIndex]
        }
    }

    private func resetFlow() {
        goalTitle = ""
        goalDescription = ""
        targetDate = calendar.date(byAdding: .month, value: 1, to: .now) ?? .now
        availableMinutes = 30
        workingDays = Set(2...6)
        previewTasks = []
        currentStep = 1
    }
}

private struct LocalGoalPlan {
    struct Step {
        let title: String
        let estimatedMinutes: Int
    }

    let steps: [Step]

    init(title: String, availableMinutes: Int) {
        let outcomes = [
            "Define the target outcome",
            "Assess the current level",
            "Prepare required resources",
            "Complete the first focused session",
            "Review early progress",
            "Improve weak areas",
            "Final review and next steps"
        ]

        steps = outcomes.map { outcome in
            Step(title: "\(title): \(outcome)", estimatedMinutes: availableMinutes)
        }
    }
}

private struct PreviewTask: Identifiable {
    let id = UUID()
    var title: String
    var dueDate: Date
}

private struct PlanPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let goalTitle: String
    let targetDate: Date
    let availableMinutes: Int
    let workingDayTitles: String
    @Binding var tasks: [PreviewTask]
    let createGoal: ([PreviewTask]) -> String?
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section("Goal") {
                LabeledContent("Title", value: goalTitle)
                LabeledContent("Target date") {
                    Text(targetDate, format: .dateTime.month().day().year())
                }
                LabeledContent("Available time", value: "\(availableMinutes) min/day")
                LabeledContent("Working days", value: workingDayTitles)
            }

            Section("Tasks") {
                ForEach($tasks) { $task in
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Task title", text: $task.title)
                        DatePicker("Due date", selection: $task.dueDate, displayedComponents: .date)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { tasks.remove(atOffsets: $0) }
                .onMove { tasks.move(fromOffsets: $0, toOffset: $1) }

                Button {
                    addTask()
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Plan Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }

            ToolbarItem(placement: .bottomBar) {
                Button("Create Goal") {
                    savePlan()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
        }
        .alert("Unable to Create Goal", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Please review the plan.")
        }
    }

    private func addTask() {
        let dueDate = tasks.map(\.dueDate).max() ?? targetDate
        tasks.append(PreviewTask(title: "New task", dueDate: dueDate))
    }

    private func savePlan() {
        errorMessage = createGoal(tasks)
    }
}

private enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday

    var id: Int { rawValue }
    var calendarWeekday: Int { rawValue }

    var title: String {
        switch self {
        case .sunday: "Sunday"
        case .monday: "Monday"
        case .tuesday: "Tuesday"
        case .wednesday: "Wednesday"
        case .thursday: "Thursday"
        case .friday: "Friday"
        case .saturday: "Saturday"
        }
    }

    var shortTitle: String {
        String(title.prefix(3))
    }
}

#Preview {
    AIView()
        .modelContainer(for: [ProjectItem.self, TaskItem.self], inMemory: true)
}
