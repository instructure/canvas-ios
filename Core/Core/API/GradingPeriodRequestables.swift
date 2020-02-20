//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public struct GetGradingPeriodsRequest: APIRequestable {
    public typealias Response = [APIGradingPeriod]

    let courseID: String

    public var path: String {
        return "courses/\(courseID)/grading_periods"
    }

    public func decode(_ data: Data) throws -> [APIGradingPeriod] {
        let decoder = APIJSONDecoder()
        let response = try decoder.decode(APIGradingPeriodResponse.self, from: data)
        return response.grading_periods
    }

    public func encode(response: [APIGradingPeriod]) throws -> Data {
        try APIJSONEncoder().encode(APIGradingPeriodResponse(grading_periods: response))
    }
}
