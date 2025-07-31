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
        id: ID = "1",
        title: String = "Grading Standard",
        context_type: String = "Course",
        context_id: ID = "1",
        points_based: Bool = true,
        scaling_factor: Double = 1.0,
        grading_scheme: [APIGradingSchemeEntry] = [.init(name: "Grading Scheme Entry", value: 1.0)]
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

public struct APIGradingStandardResponse: Codable, Equatable {
    let grading_standards: [APIGradingStandard]
}

// https://developerdocs.instructure.com/services/canvas/resources/grading_standards#method.grading_standards_api.context_show
public struct GetGradingStandardRequest: APIRequestable {
    public typealias Response = APIGradingStandard

    let contextId: String
    let contextType: String
    let gradingStandardId: String

    public var path: String {
        switch contextType {
        case "Course":
            return "courses/\(contextId)/grading_standards/\(gradingStandardId)"
        default:
            return "accounts/\(contextId)/grading_standards/\(gradingStandardId)"
        }
    }

    public func decode(_ data: Data) throws -> APIGradingStandard {
        let decoder = APIJSONDecoder()
        let response = try decoder.decode(APIGradingStandard.self, from: data)
        return response
    }

    public func encode(response: APIGradingStandard) throws -> Data {
        try APIJSONEncoder().encode(response)
    }
}
