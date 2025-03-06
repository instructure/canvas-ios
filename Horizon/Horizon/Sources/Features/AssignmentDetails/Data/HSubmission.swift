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

import Core
import Foundation
import HorizonUI

struct HSubmission: Hashable, Equatable {
    let id: String
    let assignmentID: String
    let attachments: [File]?
    let body: String?
    let type: AssignmentSubmissionType?
    let attempt: Int
    let submittedAt: Date?
    let late: Bool
    let missing: Bool
    let excused: Bool?
    let grade: String?
    let score: Double?
    let showSubmitButton: Bool
    private(set) var numberOfComments: Int?
    
    public var status: HSubmission.Status {
        if late { return .late }
        if missing { return .missing }
        if submittedAt != nil { return .submitted }
        if excused != nil { return .excused }
        return .notSubmitted
    }

    // MARK: - Init

    init(entity: GetSubmission.Model) {
        self.id = entity.id
        self.assignmentID = entity.assignmentID
        self.attachments = Array(entity.attachments ?? [])
        self.body = entity.body
        self.type = AssignmentSubmissionType(rawValue: entity.type?.rawValue ?? "")
        self.attempt = entity.attempt
        self.submittedAt = entity.submittedAt
        self.late = entity.late
        self.missing = entity.missing
        self.excused = entity.excused
        self.grade = entity.grade
        self.score = entity.score
        self.showSubmitButton = entity.assignment?.hasAttemptsLeft ?? false
        self.numberOfComments = nil
    }

    init(
        id: String,
        assignmentID: String,
        attachments: [File]? = [],
        body: String? = nil,
        type: AssignmentSubmissionType? = nil,
        attempt: Int = 10,
        submittedAt: Date? = nil,
        late: Bool = false,
        missing: Bool = false,
        excused: Bool? = nil,
        grade: String? = nil,
        score: Double? = nil,
        showSubmitButton: Bool = true,
        numberOfComments: Int? = nil
    ) {
        self.id = id
        self.assignmentID = assignmentID
        self.attachments = attachments
        self.body = body
        self.type = type
        self.attempt = attempt
        self.submittedAt = submittedAt
        self.late = late
        self.missing = missing
        self.excused = excused
        self.grade = grade
        self.score = score
        self.showSubmitButton = showSubmitButton
        self.numberOfComments = numberOfComments
    }
    
    func update(numberOfComments: Int? = nil) -> HSubmission {
        HSubmission(
            id: self.id,
            assignmentID: self.assignmentID,
            attachments: self.attachments,
            body: self.body,
            type: self.type,
            attempt: self.attempt,
            submittedAt: self.submittedAt,
            late: self.late,
            missing: self.missing,
            excused: self.excused,
            grade: self.grade,
            score: self.score,
            showSubmitButton: self.showSubmitButton,
            numberOfComments: numberOfComments
        )
    }
}

extension HSubmission {
    enum Status {
        case late
        case missing
        case submitted
        case notSubmitted
        case excused

        var text: String {
            switch self {
            case .late:
                return String(localized: "Late", bundle: .horizon)
            case .missing:
                return String(localized: "Missing", bundle: .horizon)
            case .submitted:
                return String(localized: "Submitted", bundle: .horizon)
            case .notSubmitted:
                return String(localized: "Not Submitted", bundle: .horizon)
            case .excused:
                return String(localized: "Excused", bundle: .horizon)
            }
        }
    }
}
