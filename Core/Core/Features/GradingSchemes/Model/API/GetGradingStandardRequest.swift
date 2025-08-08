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

// https://developerdocs.instructure.com/services/canvas/resources/grading_standards#method.grading_standards_api.context_show
public struct GetGradingStandardRequest: APIRequestable {
    public typealias Response = APIGradingStandard

    let context: Context
    let gradingStandardId: String

    public var path: String {
        "\(context.pathComponent)/grading_standards/\(gradingStandardId)"
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
