//
//  TasksView.swift
//  Reson
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    @State private var isPresentingAddTask = false

    private var activeTasks: [TaskItem] {
        tasks.filter { !$0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            Group {
                if activeTasks.isEmpty {
                    ContentUnavailableView(
                        "No Tasks",
                        systemImage: "checkmark.circle",
                        description: Text("Add a task to get started.")
                    )
                } else {
                    List {
                        ForEach(activeTasks) { task in
                            Button {
                                task.isCompleted.toggle()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(task.isCompleted ? .green : .secondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title)
                                            .strikethrough(task.isCompleted)
                                            .foregroundStyle(task.isCompleted ? .secondary : .primary)

                                        if let project = task.project {
                                            Label(project.title, systemImage: "folder")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }

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
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        CompletedTasksView()
                    } label: {
                        Label("Completed", systemImage: "checkmark.circle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddTask = true
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddTask) {
                AddTaskView()
            }
        }
    }
}

private struct CompletedTasksView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    private var completedTasks: [TaskItem] {
        tasks.filter(\.isCompleted)
    }

    var body: some View {
        Group {
            if completedTasks.isEmpty {
                ContentUnavailableView(
                    "No Completed Tasks",
                    systemImage: "checkmark.circle",
                    description: Text("Completed tasks will appear here.")
                )
            } else {
                List {
                    ForEach(completedTasks) { task in
                        Button {
                            task.isCompleted = false
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)

                                Text(task.title)
                                    .strikethrough()
                                    .foregroundStyle(.secondary)

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
                .listStyle(.plain)
            }
        }
        .navigationTitle("Completed")
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProjectItem.createdAt, order: .reverse) private var projects: [ProjectItem]
    @State private var title = ""
    @State private var selectedProject: ProjectItem?

    init(project: ProjectItem? = nil) {
        _selectedProject = State(initialValue: project)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Task title", text: $title)

                Picker("Project", selection: $selectedProject) {
                    Text("No Project")
                        .tag(nil as ProjectItem?)

                    ForEach(projects, id: \.id) { project in
                        Text(project.title)
                            .tag(project as ProjectItem?)
                    }
                }
            }
            .navigationTitle("New Task")
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
                        modelContext.insert(TaskItem(title: trimmedTitle, project: selectedProject))
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    TasksView()
        .modelContainer(for: [TaskItem.self, ProjectItem.self], inMemory: true)
}
