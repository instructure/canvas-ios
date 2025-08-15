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

public struct APISubmissionSummary: Codable, Equatable {
    let graded: Int
    let ungraded: Int
    let not_submitted: Int
}

#if DEBUG

extension APISubmissionSummary {
    public static func make(
        graded: Int = 1,
        ungraded: Int = 2,
        not_submitted: Int = 3
    ) -> APISubmissionSummary {
        APISubmissionSummary(
            graded: graded,
            ungraded: ungraded,
            not_submitted: not_submitted
        )
    }
}

#endif
