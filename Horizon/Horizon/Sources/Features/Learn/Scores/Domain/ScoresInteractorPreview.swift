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
    var courseID: String { "" }
    func getScores(sortedBy _: ScoreDetails.SortOption, ignoreCache: Bool) -> AnyPublisher<ScoreDetails, any Error> {
        Just(
            ScoreDetails(
                score: "25%",
                assignmentGroups: [
                    .init(
                        id: "1",
                        name: "First group",
                        groupWeight: 20,
                        assignments: [
                            HScoresAssignment(
                                id: "2",
                                name: "iOS Debugging Quiz",
                                commentsCount: 0,
                                dueAt: Date().addingTimeInterval(172800),
                                htmlUrl: URL(string: "https://horizon.com/assignment2"),
                                pointsPossible: 50,
                                score: nil,
                                state: "not_submitted",
                                isRead: false,
                                isExcused: false,
                                isLate: false,
                                isMissing: true,
                                submittedAt: nil
                            ),
                            HScoresAssignment(
                                id: "1",
                                name: "Essay on SwiftUI",
                                commentsCount: 3,
                                dueAt: Date().addingTimeInterval(86400),
                                htmlUrl: URL(string: "https://horizon.com/assignment1"),
                                pointsPossible: 100,
                                score: 95,
                                state: "graded",
                                isRead: true,
                                isExcused: false,
                                isLate: false,
                                isMissing: false,
                                submittedAt: Date().addingTimeInterval(-3600)
                            )
                        ]
                    ),
                    .init(
                        id: "2",
                        name: "Second group",
                        groupWeight: 80,
                        assignments: [
                            HScoresAssignment(
                                id: "3",
                                name: "Xcode Playground Challenge",
                                commentsCount: 5,
                                dueAt: Date().addingTimeInterval(-86400), // was due yesterday
                                htmlUrl: URL(string: "https://horizon.com/assignment3"),
                                pointsPossible: 75,
                                score: 70,
                                state: "graded",
                                isRead: false,
                                isExcused: false,
                                isLate: true,
                                isMissing: false,
                                submittedAt: Date().addingTimeInterval(-3600 * 24 * 2) // submitted 2 days ago
                            ),
                            HScoresAssignment(
                                id: "4",
                                name: "Optional Bonus Project",
                                commentsCount: 2,
                                dueAt: nil, // no due date
                                htmlUrl: URL(string: "https://horizon.com/assignment4"),
                                pointsPossible: 25,
                                score: nil,
                                state: nil,
                                isRead: true,
                                isExcused: true,
                                isLate: false,
                                isMissing: false,
                                submittedAt: nil
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
