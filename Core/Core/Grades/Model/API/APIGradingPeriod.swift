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

public struct APIGradingPeriod: Codable, Equatable {
    let id: ID
    let title: String
    let start_date: Date?
    let end_date: Date?
}

#if DEBUG
extension APIGradingPeriod {
    public static func make( id: ID = "1", title: String = "Grade Period X", start_date: Date?  = Clock.now.inCalendar.addDays(-7), end_date: Date? = Clock.now.inCalendar.addDays(7)) -> APIGradingPeriod {
        return APIGradingPeriod(
            id: id,
            title: title,
            start_date: start_date,
            end_date: end_date
        )
    }
}
#endif

public struct APIGradingPeriodResponse: Codable, Equatable {
    let grading_periods: [APIGradingPeriod]
}

// https://canvas.instructure.com/doc/api/grading_periods.html#method.grading_periods.index
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
