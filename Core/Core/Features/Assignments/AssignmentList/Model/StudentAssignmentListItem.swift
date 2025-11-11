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
import SwiftUI

struct StudentAssignmentListItem: Equatable, Identifiable {

    struct SubItem: Equatable, Identifiable {
        let tag: String
        let title: String

        let dueDate: String
        let submissionStatus: SubmissionStatusLabel.Model
        let score: String?
        let scoreA11yLabel: String?

        var id: String { tag }
    }

    let id: String
    let title: String
    let icon: Image

    let dueDates: [String]
    let submissionStatus: SubmissionStatusLabel.Model
    let score: String?
    let scoreA11yLabel: String?

    let subItems: [SubItem]?

    let route: URL?

    init(
        assignment: Assignment,
        userId: String?,
        dateTextsProvider: AssignmentDateTextsProvider = .live
    ) {
        let submission: Submission?
        if let userId {
            submission = assignment.submissions?.first { $0.userID == userId }
        } else {
            submission = assignment.submission
        }

        let hasSubAssignments = assignment.hasSubAssignments

        self.id = assignment.id
        self.title = assignment.name
        self.icon = assignment.icon.asImage

        self.dueDates = dateTextsProvider.summarizedDueDates(for: assignment)

        let status = submission?.status ?? .notSubmitted
        self.submissionStatus = .init(status: status)

        let hasPointsPossible = assignment.pointsPossible != nil
        let score = hasPointsPossible && status != .excused
            ? GradeFormatter.string(from: assignment, submission: submission, style: .medium)
            : nil
        self.score = score
        self.scoreA11yLabel = score.flatMap {
            [String(localized: "Grade", bundle: .core), GradeFormatter.a11yString(from: $0)]
                .accessibilityJoined()
        }

        self.route = assignment.htmlURL

        if hasSubAssignments {
            self.subItems = assignment.checkpoints
                .map { checkpoint in
                    let subSubmission = submission?.subAssignmentSubmissions
                        .first { $0.subAssignmentTag == checkpoint.tag }

                    let status = subSubmission?.status ?? .notSubmitted

                    var score: String?
                    if let pointsPossible = checkpoint.pointsPossible, status != .excused {
                        score = GradeFormatter.string(
                            pointsPossible: pointsPossible,
                            gradingType: assignment.gradingType,
                            gradingScheme: assignment.gradingScheme,
                            hideScores: assignment.hideQuantitativeData,
                            style: .medium,
                            isExcused: false,
                            score: subSubmission?.score,
                            normalizedScore: (subSubmission?.score).map { $0 / pointsPossible },
                            grade: subSubmission?.grade
                        )
                    }
                    let scoreA11yLabel = score.flatMap {
                        [String(localized: "Grade", bundle: .core), GradeFormatter.a11yString(from: $0)]
                            .accessibilityJoined()
                    }

                    return SubItem(
                        tag: checkpoint.tag,
                        title: checkpoint.title,
                        dueDate: DueDateFormatter.format(checkpoint.dueDate, lockDate: checkpoint.lockDate),
                        submissionStatus: .init(status: status),
                        score: score,
                        scoreA11yLabel: scoreA11yLabel
                    )
                }
        } else {
            self.subItems = nil
        }
    }
}

#if DEBUG

extension StudentAssignmentListItem {
    private init(
        id: String,
        title: String,
        icon: Image,
        dueDates: [String],
        submissionStatus: SubmissionStatusLabel.Model,
        score: String?,
        scoreA11yLabel: String?,
        subItems: [SubItem]?,
        route: URL?
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.dueDates = dueDates
        self.submissionStatus = submissionStatus
        self.score = score
        self.scoreA11yLabel = scoreA11yLabel
        self.subItems = subItems
        self.route = route
    }

    public static func make(
        id: String = "",
        title: String = "",
        icon: Image = .emptyLine,
        dueDates: [String] = [],
        submissionStatus: SubmissionStatusLabel.Model = .init(text: "", icon: .emptyLine, color: .clear),
        score: String? = nil,
        scoreA11yLabel: String? = nil,
        subItems: [SubItem]? = nil,
        route: URL? = nil
    ) -> Self {
        self.init(
            id: id,
            title: title,
            icon: icon,
            dueDates: dueDates,
            submissionStatus: submissionStatus,
            score: score,
            scoreA11yLabel: scoreA11yLabel,
            subItems: subItems,
            route: route
        )
    }
}

extension StudentAssignmentListItem.SubItem {
    public static func make(
        tag: String = "",
        title: String = "",
        dueDate: String = "",
        submissionStatus: SubmissionStatusLabel.Model = .init(text: "", icon: .emptyLine, color: .clear),
        score: String? = nil,
        scoreA11yLabel: String? = nil
    ) -> Self {
        self.init(
            tag: tag,
            title: title,
            dueDate: dueDate,
            submissionStatus: submissionStatus,
            score: score,
            scoreA11yLabel: scoreA11yLabel
        )
    }
}

#endif
