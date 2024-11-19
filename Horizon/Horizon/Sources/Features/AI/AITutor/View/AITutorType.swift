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
            String(localized: "Quiz me on this material", bundle: .horizon)
        case .summary:
            String(localized: "Summarize this material", bundle: .horizon)
        case .takeAway:
            String(localized: "Give me key takeaways", bundle: .horizon)
        case .tellMeMore:
            String(localized: "Tell me more about this topic", bundle: .horizon)
        case .flashCard:
            String(localized: "Generate some study flashcards", bundle: .horizon)
        }
    }
}
