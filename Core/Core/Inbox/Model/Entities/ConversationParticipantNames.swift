//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public extension Array where Element == ConversationParticipant {

    var names: String {
        if count > 6 {
            let sample = prefix(5).map(\.displayName)
            let sampledNames = sample.joined(separator: ", ")
            let remainingNamesCount = count - sample.count
            return NSLocalizedString("\(sampledNames) + \(remainingNamesCount) more", bundle: .core, comment: "(Alice, Bob) + (2) more")
        } else {
            return map(\.displayName).joined(separator: ", ")
        }
    }
}
