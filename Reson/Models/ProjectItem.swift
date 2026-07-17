//
//  ProjectItem.swift
//  Reson
//

import Foundation
import SwiftData

@Model
final class ProjectItem {
    var id: UUID
    var title: String
    var projectDescription: String
    var createdAt: Date
    var targetDate: Date?
    var isArchived: Bool
    var tasks: [TaskItem] = []

    init(
        id: UUID = UUID(),
        title: String,
        projectDescription: String = "",
        createdAt: Date = .now,
        targetDate: Date? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.title = title
        self.projectDescription = projectDescription
        self.createdAt = createdAt
        self.targetDate = targetDate
        self.isArchived = isArchived
    }
}
