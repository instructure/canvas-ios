//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct QuizSubmissionListItem: Equatable {
    public let id: String
    public let displayName: String
    public let name: String?
    public let status: QuizSubmissionWorkflowState
    public let score: String?
    public let avatarURL: URL?

    public static func make(
        users: [QuizSubmissionUser],
        submissions: [QuizSubmission],
        isAnonymous: Bool
    ) -> [QuizSubmissionListItem] {
        users.enumerated().map { index, user in
            var status: QuizSubmissionWorkflowState = .untaken
            var score: String?
            if let submission = submissions.first(where: { $0.userID == user.id }) {
                status = submission.workflowState
                if let submissionScore = submission.score {
                    let truncated = GradeFormatter.truncate(submissionScore)
                    score = String(truncated.stringValue)
                }
            }

            let displayName: String
            let avatarURL: URL?
            let name: String?

            if isAnonymous {
                displayName = String(localized: "Student \(index + 1)", bundle: .teacher)
                avatarURL = nil
                name = nil
            } else {
                displayName = User.displayName(user.name, pronouns: user.pronouns)
                avatarURL = user.avatarURL
                name = user.name
            }

            return QuizSubmissionListItem(
                id: user.id,
                displayName: displayName,
                name: name,
                status: status,
                score: score,
                avatarURL: avatarURL
            )
        }
    }
}

#if DEBUG

public extension QuizSubmissionListItem {
    static func make(id _: String = "0")
        -> QuizSubmissionListItem {
        let mockObject = QuizSubmissionListItem(id: "1", displayName: "Student", name: "Student", status: .complete, score: "5", avatarURL: nil)
        return mockObject
    }
}

public extension Array where Element == QuizSubmissionListItem {
    static func make(count: Int)
        -> [QuizSubmissionListItem] {
        (0 ..< count).reduce(into: []) { partialResult, index in
            partialResult.append(.make(id: "\(index)"))
        }
    }
}

#endif
