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

import Combine
import Foundation

class ScoresInteractorPreview: ScoresInteractor {
    func getScores(sortedBy _: ScoreDetails.SortOption, refresh: Bool) -> AnyPublisher<ScoreDetails, any Error> {
        Just(
            ScoreDetails(
                score: "25%",
                assignmentGroups: [
                    .init(
                        id: "1",
                        name: "First group",
                        groupWeight: 20,
                        assignments: [
                            .init(
                                id: "1",
                                htmlURL: nil,
                                name: "First assignment",
                                details: nil,
                                pointsPossible: 10,
                                dueAt: Date.now,
                                allowedAttempts: 10,
                                submissionTypes: [],
                                courseID: "1",
                                courseName: "Course 1",
                                workflowState: nil,
                                submittedAt: Date.now,
                                submissions: [
                                    .init(id: "1", assignmentID: "1", score: 5)
                                ]
                            ),
                            .init(
                                id: "2",
                                htmlURL: nil,
                                name: "Second assignment",
                                details: nil,
                                pointsPossible: 5,
                                dueAt: Date.now,
                                allowedAttempts: 10,
                                submissionTypes: [],
                                courseID: "1",
                                courseName: "Course 1",
                                workflowState: nil,
                                submittedAt: Date.now,
                                submissions: [
                                    .init(id: "2", assignmentID: "2", score: 3)
                                ]
                            )
                        ]
                    ),
                    .init(
                        id: "2",
                        name: "Second group",
                        groupWeight: 80,
                        assignments: [
                            .init(
                                id: "3",
                                htmlURL: nil,
                                name: "Third assignment",
                                details: nil,
                                pointsPossible: 10,
                                dueAt: Date.now,
                                allowedAttempts: 10,
                                submissionTypes: [],
                                courseID: "1",
                                courseName: "Course 1",
                                workflowState: nil,
                                submittedAt: Date.now,
                                submissions: [
                                    .init(id: "3", assignmentID: "1", score: 1)
                                ]
                            ),
                            .init(
                                id: "4",
                                htmlURL: nil,
                                name: "Fourth assignment",
                                details: nil,
                                pointsPossible: 5,
                                dueAt: Date.now,
                                allowedAttempts: 10,
                                submissionTypes: [],
                                courseID: "1",
                                courseName: "Course 1",
                                workflowState: nil,
                                submittedAt: Date.now,
                                submissions: [
                                    .init(id: "4", assignmentID: "1", score: nil)
                                ]
                            )
                        ]
                    )
                ],
                sortOption: .dueDate
            )
        )
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
}
