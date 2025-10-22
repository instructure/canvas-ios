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

public struct AssignmentCheckpointsViewModel {

    public struct CheckpointItem: Identifiable {
        public let id: String
        public let title: String
        public let statusLabel: SubmissionStatusLabel.Model
        public let score: String?

        public init(
            id: String,
            title: String,
            statusLabel: SubmissionStatusLabel.Model,
            score: String?
        ) {
            self.id = id
            self.title = title
            self.statusLabel = statusLabel
            self.score = score
        }
    }

    public let checkpointItems: [CheckpointItem]

    public init(checkpointItems: [CheckpointItem]) {
        self.checkpointItems = checkpointItems
    }

    public init(assignment: Assignment, submission: Submission?) {
        guard assignment.hasSubAssignments else {
            self.checkpointItems = []
            return
        }

        self.checkpointItems = assignment.checkpoints.map { checkpoint in
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

            return CheckpointItem(
                id: checkpoint.tag,
                title: checkpoint.title,
                statusLabel: .init(status: status),
                score: score
            )
        }
    }
}
