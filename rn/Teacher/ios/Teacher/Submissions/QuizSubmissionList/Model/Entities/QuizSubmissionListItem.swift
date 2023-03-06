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
import CoreData

// TODO: Decide if this should be a CoreData Entity in the model layer or an in-memory viewmodel object in the viewmodel layer
public struct QuizSubmissionListItem: Equatable {
    public let id: String
    public let name: String
    public let status: QuizSubmissionWorkflowState
    public let score: String?
    public let avatarURL: URL?
}

#if DEBUG

public extension QuizSubmissionListItem {
    static func make(id: String = "0")
    -> QuizSubmissionListItem {
        let mockObject = QuizSubmissionListItem(id: "1", name: "Student", status: .complete, score: "5", avatarURL: nil)
        return mockObject
    }
}

public extension Array where Element == QuizSubmissionListItem {

    static func make(count: Int)
    -> [QuizSubmissionListItem] {
        (0..<count).reduce(into: [], { partialResult, index in
            partialResult.append(.make(id: "\(index)"))
        })
    }
}

#endif
