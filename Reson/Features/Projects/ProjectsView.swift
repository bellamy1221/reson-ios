//
//  ProjectsView.swift
//  Reson
//

import SwiftUI
import SwiftData

struct ProjectsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProjectItem.createdAt, order: .reverse) private var projects: [ProjectItem]
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    @State private var isPresentingAddProject = false

    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    ContentUnavailableView(
                        "No Projects",
                        systemImage: "folder",
                        description: Text("Add a project to get started.")
                    )
                } else {
                    List {
                        ForEach(projects, id: \.id) { project in
                            NavigationLink {
                                ProjectDetailView(project: project)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(project.title)
                                        .font(.headline)

                                    if !project.projectDescription.isEmpty {
                                        Text(project.projectDescription)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }

                                    if let targetDate = project.targetDate {
                                        Label(
                                            targetDate.formatted(date: .abbreviated, time: .omitted),
                                            systemImage: "calendar"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    delete(project)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddProject = true
                    } label: {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddProject) {
                AddProjectView()
            }
        }
    }

    private func delete(_ project: ProjectItem) {
        for task in tasks where task.project?.id == project.id {
            task.project = nil
        }
        modelContext.delete(project)
    }
}

struct ProjectDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    let project: ProjectItem
    @State private var isPresentingAddTask = false

    private var assignedTasks: [TaskItem] {
        tasks.filter { $0.project?.id == project.id }
    }

    var body: some View {
        List {
            Section("Details") {
                Text(project.title)
                    .font(.headline)

                if !project.projectDescription.isEmpty {
                    Text(project.projectDescription)
                }

                if let targetDate = project.targetDate {
                    LabeledContent("Target Date") {
                        Text(targetDate, format: .dateTime.month().day().year())
                    }
                }
            }

            Section("Progress") {
                Text("Progress tracking will appear here.")
                    .foregroundStyle(.secondary)
            }

            Section("Related Tasks") {
                if assignedTasks.isEmpty {
                    ContentUnavailableView(
                        "No Assigned Tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Create a task for this project to see it here.")
                    )
                } else {
                    ForEach(assignedTasks, id: \.id) { task in
                        Button {
                            task.isCompleted.toggle()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(task.isCompleted ? .green : .secondary)

                                Text(task.title)
                                    .strikethrough(task.isCompleted)
                                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                        .swipeActions {
                            Button(role: .destructive) {
                                modelContext.delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Project")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingAddTask = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddTask) {
            AddTaskView(project: project)
        }
    }
}

private struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var projectDescription = ""
    @State private var includesTargetDate = false
    @State private var targetDate = Date.now

    var body: some View {
        NavigationStack {
            Form {
                Section("Project") {
                    TextField("Title", text: $title)
                    TextField("Description (Optional)", text: $projectDescription, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Schedule") {
                    Toggle("Target Date", isOn: $includesTargetDate)

                    if includesTargetDate {
                        DatePicker("Date", selection: $targetDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        modelContext.insert(
                            ProjectItem(
                                title: trimmedTitle,
                                projectDescription: projectDescription,
                                targetDate: includesTargetDate ? targetDate : nil
                            )
                        )
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ProjectsView()
        .modelContainer(for: [ProjectItem.self, TaskItem.self], inMemory: true)
}
