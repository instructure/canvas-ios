//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

struct CourseCardModel: Identifiable, Equatable {
    let id: String
    let name: String
    let imageURL: URL?
    let progress: Double
    let lastActivityAt: Date?
    let programs: [ProgramInfo]
    let currentLearningObject: LearningObjectInfo?

    struct ProgramInfo: Identifiable, Equatable {
        let id: String
        let name: String
    }

    struct LearningObjectInfo: Equatable {
        let name: String
        let moduleTitle: String
        let type: LearningObjectType?
        let dueDate: String?
        let estimatedDuration: String?
        let url: URL?
    }

    var progressPercentage: String {
        let percentage = Int(progress.rounded())
        return "\(percentage)% complete"
    }

    var hasPrograms: Bool {
        !programs.isEmpty
    }

    var primaryProgram: ProgramInfo? {
        programs.first
    }

    var hasCurrentLearningObject: Bool {
        currentLearningObject != nil
    }
}

extension CourseCardModel {
    init(from course: HCourse) {
        self.id = course.id
        self.name = course.name
        if let imageUrlString = course.imageUrl, let imageUrl = URL(string: imageUrlString) {
            self.imageURL = imageUrl
        } else {
            self.imageURL = nil
        }
        self.progress = course.progress
        self.lastActivityAt = nil
        self.programs = course.programs.map { program in
            ProgramInfo(id: program.id, name: program.name)
        }

        if let currentLearningObject = course.currentLearningObject {
            self.currentLearningObject = LearningObjectInfo(
                name: currentLearningObject.learningObjectName,
                moduleTitle: currentLearningObject.moduleTitle,
                type: currentLearningObject.type,
                dueDate: currentLearningObject.dueDate,
                estimatedDuration: currentLearningObject.estimatedTime,
                url: currentLearningObject.url
            )
        } else {
            self.currentLearningObject = nil
        }
    }
}
