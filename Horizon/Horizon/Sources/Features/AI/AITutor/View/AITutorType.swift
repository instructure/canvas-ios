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

import Foundation

enum AITutorType: CaseIterable {
    case quiz
    case summary
    case takeAway
    case tellMeMore
    case flashCard

    var titel: String {
        switch self {
        case .quiz:
            "Quiz me on this material"
        case .summary:
            "Summarize this material"
        case .takeAway:
            "Give me key takeaways"
        case .tellMeMore:
            "Tell me more about this topic"
        case .flashCard:
            "Generate some study flashcards"
        }
    }
}
