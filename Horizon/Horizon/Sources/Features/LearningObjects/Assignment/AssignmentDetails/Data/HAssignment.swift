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
import UniformTypeIdentifiers

struct HAssignment: Identifiable {
    let id: String
    let htmlURL: URL?
    let name: String
    let duration: String = "20 mins"
    let details: String?
    let pointsPossible: Double?
    let dueAt: Date?
    let dueAtString: String?
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

    let submissions: [HSubmission]

    var mostRecentSubmission: HSubmission? {
        submissions.first
    }

    private static let noDataString = "-"

    var pointsResult: String {
        if let pointsPossibleString {
            return "\(mostRecentSubmissionScoreString)/\(pointsPossibleString)"
        } else {
            return Self.noDataString
        }
    }

    private var mostRecentSubmissionScoreString: String {
        if let mostRecentSubmission = mostRecentSubmission, let score = mostRecentSubmission.score {
            return GradeFormatter.numberFormatter.string(
                from: NSNumber(value: score)
            ) ?? Self.noDataString
        } else {
            return Self.noDataString
        }
    }

    private var pointsPossibleString: String? {
        if let pointsPossible {
            return GradeFormatter.numberFormatter.string(
                from: NSNumber(value: pointsPossible)
            )
        } else {
            return nil
        }
    }

    init(
        id: String,
        htmlURL: URL?,
        name: String,
        details: String?,
        pointsPossible: Double?,
        dueAt: Date?,
        allowedAttempts: Int,
        submissionTypes: [SubmissionType],
        courseID: String,
        courseName: String,
        workflowState: SubmissionWorkflowState?,
        submittedAt: Date?,
        submissions: [HSubmission]
    ) {
        self.id = id
        self.htmlURL = htmlURL
        self.name = name
        self.details = details
        self.pointsPossible = pointsPossible
        self.dueAt = dueAt
        if let dueAt {
            self.dueAtString = Self.dateFormatter.string(from: dueAt)
        } else {
            self.dueAtString = nil
        }
        self.allowedAttempts = allowedAttempts
        self.submissionTypes = submissionTypes
        self.courseID = courseID
        self.courseName = courseName
        self.workflowState = workflowState
        self.submittedAt = submittedAt
        self.submissions = submissions
    }

    init(from assignment: Assignment) {
        self.id = assignment.id
        self.htmlURL = assignment.htmlURL
        self.name = assignment.name
        self.details = assignment.details
        self.pointsPossible = assignment.pointsPossible
        self.dueAt = assignment.dueAt
        if let dueAt {
            self.dueAtString = Self.dateFormatter.string(from: dueAt)
        } else {
            self.dueAtString = nil
        }
        self.allowedAttempts = assignment.allowedAttempts
        self.submissionTypes = assignment.submissionTypes
        self.workflowState = assignment.submission?.workflowState
        self.submittedAt = assignment.submission?.submittedAt
        self.courseID = assignment.id
        self.courseName = assignment.course?.name ?? ""
        self.showSubmitButton = false
        self.allowedExtensions = assignment.allowedExtensions
        self.externalToolContentID = assignment.externalToolContentID
        self.isQuizLTI = assignment.isQuizLTI
        if let submissions = assignment.submissions {
            self.submissions = Array(submissions).map { HSubmission(entity: $0) }
        } else {
            self.submissions = []
        }
        self.showSubmitButton = assignment.hasAttemptsLeft && (assignmentSubmissionTypes.first != .externalTool)
    }

    func update(submissions: [HSubmission]) -> HAssignment {
        HAssignment(
            id: id,
            htmlURL: htmlURL,
            name: name,
            details: details,
            pointsPossible: pointsPossible,
            dueAt: dueAt,
            allowedAttempts: allowedAttempts,
            submissionTypes: submissionTypes,
            courseID: courseID,
            courseName: courseName,
            workflowState: workflowState,
            submittedAt: submittedAt,
            submissions: submissions
        )
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

    var allowedContentTypes: [UTType] {
        let types = fileExtensions.compactMap { $0.uttype }
        return types.isEmpty ? [.item] : types
    }

    var allowedFileExtensions: String {
        allowedExtensions.compactMap { $0.split(separator: ".").last }
            .map { ".\($0)" }
            .joined(separator: ", ")
    }

    var attemptCount: String? {
        allowedAttempts > 0 ? "\(allowedAttempts)" : String(localized: "Unlimited", bundle: .horizon)
    }

    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current
        return formatter
    }()
}

// swiftlint:disable line_length
extension HAssignment {
    static func mock() -> HAssignment {
        HAssignment(
            id: "1",
            htmlURL: nil,
            name: "Text assignment",
            details: """
            Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.

            The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
            """,
            pointsPossible: 10,
            dueAt: Date.now,
            allowedAttempts: -1,
            submissionTypes: [.online_text_entry],
            courseID: "1",
            courseName: "Design Thinking Workshop",
            workflowState: .unsubmitted,
            submittedAt: Date(),
            submissions: []
        )
    }
}

// swiftlint:enable line_length
