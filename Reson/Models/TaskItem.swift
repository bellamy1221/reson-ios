//
//  TaskItem.swift
//  Reson
//

import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var dueDate: Date?
    var wasSkipped: Bool = false
    var skipReason: String?
    var project: ProjectItem?

    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdAt: Date = .now,
        dueDate: Date? = nil,
        wasSkipped: Bool = false,
        skipReason: String? = nil,
        project: ProjectItem? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.wasSkipped = wasSkipped
        self.skipReason = skipReason
        self.project = project
    }
}
