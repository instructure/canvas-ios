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

public protocol GradingScheme {
    var entries: [GradingSchemeEntry] { get }

    func convertNormalizedScoreToLetterGrade(_ normalizedScore: Double) -> String?
    func formattedScore(from value: Double) -> String?
}

public extension GradingScheme {

    func convertNormalizedScoreToLetterGrade(_ normalizedScore: Double) -> String? {
        // Teachers can add extra points so the "normalized" score can be higher than 1.0. But 10 would be very suspicious.
        assert(abs(normalizedScore) < 10)

        return entries.first { normalizedScore >= $0.value }?.name
    }
}
