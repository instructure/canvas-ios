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

/// These are predefined responses from which a learner can select
enum AssistStaticLearnerResponse {
    case selectCourse(courseName: String, courseID: String)
    case review

    /// Based on a selected learner response, compose a response for the AI Assistant
    func assistChatResponse(chatHistory: [AssistChatMessage]) -> AssistChatResponse {
        switch self {
        case .selectCourse(let courseName, _):
            return .courseHelp(
                courseName: courseName,
                chatHistory: chatHistory + [AssistChatMessage(userResponse: chip)]
            )
        case .review:
            return .review(chatHistory: chatHistory + [AssistChatMessage(userResponse: chip)])
        }
    }

    var chip: String {
        switch self {
        case .selectCourse(let courseName, _):
            return courseName
        case .review:
            return String(localized: "Help me review material I've already studied")
        }
    }
}
