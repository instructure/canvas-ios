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

struct CourseListWidgetModel: Identifiable, Equatable, ProgressStatusProvidable {
    let id: String
    let enrollmentID: String
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
        let id: String
        let moduleTitle: String
        let type: LearningObjectType?
        let dueDate: String?
        let estimatedDuration: String?
        let url: URL?
    }

    var progressPercentage: String {
        let percentage = Int(progress.rounded())
        return String(format: "%d%%", percentage)
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

    var isCourseCompleted: Bool {
        progress.rounded() == 100 && !hasCurrentLearningObject
    }

    var buttonCourseTitle: String {
        switch progress {
        case 100.0:
            String(localized: "View course")
        case 0.0:
            String(localized: "Start learning")
        default:
            String(localized: "Resume learning")
        }
    }

    var status: ProgressStatus {
        .init(progress: progress)
    }

    var accessibilityDescription: String {
        if id == "mock-course-id" {
            return String(localized: "Courses are loading", bundle: .horizon)
        }

        var description = String.localizedStringWithFormat(
            String(localized: "Course: %@. ", bundle: .horizon),
            name
        )

        if programs.isNotEmpty {
            let programsSeparated = programs.map(\.name).joined(separator: ", ")
            if programsSeparated.isNotEmpty {
                description += String.localizedStringWithFormat(
                    String(localized: "Part of %@. ", bundle: .horizon),
                    programsSeparated
                )
            }
        }

        description += String.localizedStringWithFormat(
            String(localized: "Progress: %d percent complete. ", bundle: .horizon),
            Int(progress.rounded())
        )
        if let learningObject = currentLearningObject {
            description += String.localizedStringWithFormat(
                String(localized: "Current learning object: %@. ", bundle: .horizon),
                learningObject.name
            )
            if let type = learningObject.type {
                description += String.localizedStringWithFormat(
                    String(localized: "Type: %@. ", bundle: .horizon),
                    type.rawValue
                )
            }
            if let dueDate = learningObject.dueDate {
                description += String.localizedStringWithFormat(
                    String(localized: "Due at %@. ", bundle: .horizon),
                    dueDate
                )
            }
            if let estimatedDuration = learningObject.estimatedDuration {
                description += String.localizedStringWithFormat(
                    String(localized: "Estimated duration: %@. ", bundle: .horizon),
                    estimatedDuration
                )
            }
        }

        return description
    }

    var accessiblityHintString: String {
        if hasCurrentLearningObject {
            String(localized: "Double tap to open learning object", bundle: .horizon)
        } else {
            String(localized: "Double tap to open course", bundle: .horizon)
        }
    }

    func viewProgramAccessibilityString(_ programName: String) -> String {
        String.localizedStringWithFormat(
            String(localized: "Open %@", bundle: .horizon),
            programName
        )
    }
}

extension CourseListWidgetModel {
    init(from course: HCourse) {
        id = course.id
        name = course.name
        enrollmentID = course.enrollmentID
        if let imageUrlString = course.imageUrl, let imageUrl = URL(string: imageUrlString) {
            imageURL = imageUrl
        } else {
            imageURL = nil
        }
        progress = course.progress
        lastActivityAt = nil
        programs = course.programs.map { program in
            ProgramInfo(id: program.id, name: program.name)
        }

        if let currentLearningObject = course.currentLearningObject {
            self.currentLearningObject = LearningObjectInfo(
                name: currentLearningObject.learningObjectName,
                id: currentLearningObject.learningObjectID,
                moduleTitle: currentLearningObject.moduleTitle,
                type: currentLearningObject.type,
                dueDate: currentLearningObject.dueDate,
                estimatedDuration: currentLearningObject.estimatedTime,
                url: currentLearningObject.url
            )
        } else {
            currentLearningObject = nil
        }
    }
}
