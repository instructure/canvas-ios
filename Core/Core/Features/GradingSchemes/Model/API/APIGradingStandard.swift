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

public struct APIGradingStandard: Codable, Equatable {
    let id: ID
    let title: String
    let context_type: String  // Course or Account
    let context_id: ID
    let points_based: Bool
    let scaling_factor: Double
    let grading_scheme: [APIGradingSchemeEntry]
}

#if DEBUG

extension APIGradingStandard {
    public static func make(
        id: ID = "",
        title: String = "",
        context_type: String = "",
        context_id: ID = "",
        points_based: Bool = true,
        scaling_factor: Double = 1.0,
        grading_scheme: [APIGradingSchemeEntry] = [.make()]
    ) -> APIGradingStandard {
        return APIGradingStandard(
            id: id,
            title: title,
            context_type: context_type,
            context_id: context_id,
            points_based: points_based,
            scaling_factor: scaling_factor,
            grading_scheme: grading_scheme
        )
    }
}

#endif
