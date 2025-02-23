//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core

struct HAssignment {
    let id: String
    let name: String
    let duration: String = "20 mins"
    let details: String?
    let pointsPossible: Double?
    let dueAt: String
    let allowedAttempts: Int
    let submissionTypes: [SubmissionType]
    let courseID: String
    let courseName: String
    let courseState: String = "Not Started"
    let courseProgress: Double = 0.75
    let courseDueDate: String = "Due 01/12/2024"
    let workflowState: SubmissionWorkflowState?
    let submittedAt: Date?
    var showSubmitButton = false
    var allowedExtensions: [String] = []
    var externalToolContentID: String?
    var isQuizLTI: Bool?

    init(
        id: String,
        name: String,
        details: String?,
        pointsPossible: Double?,
        dueAt: String,
        allowedAttempts: Int,
        submissionTypes: [SubmissionType],
        courseID: String,
        courseName: String,
        workflowState: SubmissionWorkflowState?,
        submittedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.pointsPossible = pointsPossible
        self.dueAt = dueAt
        self.allowedAttempts = allowedAttempts
        self.submissionTypes = submissionTypes
        self.courseID = courseID
        self.courseName = courseName
        self.workflowState = workflowState
        self.submittedAt = submittedAt
    }

    init(from assignment: Assignment) {
        self.id = assignment.id
        self.name = assignment.name
        self.details = assignment.details
        self.pointsPossible = assignment.pointsPossible
        self.dueAt = assignment.dueText
        self.allowedAttempts = assignment.allowedAttempts
        self.submissionTypes = assignment.submissionTypes
        self.workflowState = assignment.submission?.workflowState
        self.submittedAt = assignment.submission?.submittedAt
        self.courseID = assignment.id
        self.courseName = assignment.course?.name ?? ""
        self.showSubmitButton = assignment.hasAttemptsLeft && (assignmentSubmissionTypes.first != .externalTool)
        self.allowedExtensions = assignment.allowedExtensions
        self.externalToolContentID = assignment.externalToolContentID
        self.isQuizLTI = assignment.isQuizLTI
    }

    var isUnsubmitted: Bool {
        workflowState == .unsubmitted || submittedAt == nil
    }

    var assignmentSubmissionTypes: [AssignmentSubmissionType] {
        submissionTypes.compactMap { AssignmentSubmissionType(rawValue: $0.rawValue) }
    }

    var fileExtensions: [UTI] {
        allowedExtensions.compactMap { UTI(extension: $0) }
    }

    var allowedFileExtensions: String {
        allowedExtensions.compactMap { $0.split(separator: ".").last }
            .map { ".\($0)" }
            .joined(separator: ", ")
    }

    var attemptCount: String? {
        allowedAttempts > 0 ? "\(allowedAttempts)" : String(localized: "Unlimited", bundle: .horizon)
    }
}

// swiftlint:disable line_length
extension HAssignment {
    static func mock() -> HAssignment {
        HAssignment(
            id: "1",
            name: "Text assignment",
            details: """
            Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.

            The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
            """,
            pointsPossible: 10,
            dueAt: "01/12/2024",
            allowedAttempts: -1,
            submissionTypes: [.online_text_entry],
            courseID: "1",
            courseName: "Design Thinking Workshop",
            workflowState: .unsubmitted,
            submittedAt: Date()
        )
    }
}

// swiftlint:enable line_length
