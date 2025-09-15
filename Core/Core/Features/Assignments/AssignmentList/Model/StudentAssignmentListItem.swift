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

        var id: String { tag }
    }

    let id: String
    let title: String
    let icon: Image

    let dueDates: [String]
    let submissionStatus: SubmissionStatusLabel.Model
    let score: String?

    let subAssignments: [SubItem]?

    let route: URL?

    init(assignment: Assignment) {
        let hasSubAssignments = assignment.hasSubAssignments

        self.id = assignment.id
        self.title = assignment.name
        self.icon = assignment.icon.asImage

        if hasSubAssignments {
            self.dueDates = assignment.checkpoints
                .map { DueDateSummary($0.dueDate, lockDate: $0.lockDate) }
                .reduceIfNeeded()
                .map(\.text)
        } else {
            self.dueDates = [
                DueDateFormatter.format(assignment.dueAt, lockDate: assignment.lockAt)
            ]
        }

        self.submissionStatus = .init(status: assignment.submission?.statusNew ?? .notSubmitted)
        let hasPointsPossible = assignment.pointsPossible != nil
        self.score = hasPointsPossible ? GradeFormatter.string(from: assignment, style: .medium) : nil
        self.route = assignment.htmlURL

        if hasSubAssignments {
            self.subAssignments = assignment.checkpoints
                .map { checkpoint in
                    let subSubmission = assignment.submission?.subAssignmentSubmissions
                        .first { $0.subAssignmentTag == checkpoint.tag }

                    return .init(
                        tag: checkpoint.tag,
                        title: checkpoint.discussionCheckpointStep?.text ?? checkpoint.assignmentName,
                        dueDate: DueDateFormatter.format(checkpoint.dueDate, lockDate: checkpoint.lockDate),
                        submissionStatus: .init(status: subSubmission?.status ?? .notSubmitted),
                        score: String(subSubmission?.score ?? -1) // TODO
                    )
                }
        } else {
            self.subAssignments = nil
        }
    }
}

private extension Submission {
    // TODO: move this to `Submission.status` once `SubmissionStatusOld` is removed in MBL-19323
    var statusNew: SubmissionStatus {
        .init(
            isLate: late,
            isMissing: missing,
            isExcused: excused ?? false,
            isSubmitted: submittedAt != nil,
            isGraded: workflowState == .graded && score != nil,
            customStatusId: customGradeStatusId,
            customStatusName: customGradeStatusName,
            submissionType: type ?? assignment?.submissionTypes.first,
            isGradeBelongToCurrentSubmission: gradeMatchesCurrentSubmission
        )
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
        subAssignments: [SubItem]?,
        route: URL?
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.dueDates = dueDates
        self.submissionStatus = submissionStatus
        self.score = score
        self.subAssignments = subAssignments
        self.route = route
    }

    public static func make(
        id: String = "",
        title: String = "",
        icon: Image = .emptyLine,
        dueDates: [String] = [],
        submissionStatus: SubmissionStatusLabel.Model = .init(text: "", icon: .emptyLine, color: .clear),
        score: String? = nil,
        subAssignments: [SubItem]? = nil,
        route: URL? = nil
    ) -> Self {
        self.init(
            id: id,
            title: title,
            icon: icon,
            dueDates: dueDates,
            submissionStatus: submissionStatus,
            score: score,
            subAssignments: subAssignments,
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
        score: String? = nil
    ) -> Self {
        self.init(
            tag: tag,
            title: title,
            dueDate: dueDate,
            submissionStatus: submissionStatus,
            score: score
        )
    }
}

#endif
