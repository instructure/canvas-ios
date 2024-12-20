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

public extension Array where Element == APIConversationParticipant {

    var names: String {
        let maxNamesCount = 3

        if count > maxNamesCount {
            let sample = prefix(maxNamesCount - 1).map { $0.displayName.trimmingCharacters(in: .whitespacesAndNewlines) }
            let sampledNames = sample.joined(separator: ", ")
            let remainingNamesCount = count - sample.count
            return String(localized: "\(sampledNames) + \(remainingNamesCount) more", bundle: .core, comment: "(Alice, Bob) + (2) more")
        } else {
            return map(\.displayName).joined(separator: ", ")
        }
    }
}
