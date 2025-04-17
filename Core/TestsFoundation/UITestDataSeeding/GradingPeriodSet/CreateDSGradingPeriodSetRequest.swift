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

import Core
import Foundation

// https://canvas.instructure.com/doc/api/grading_period_sets.html#method.grading_period_sets.create
public struct CreateDSGradingPeriodSetRequest: APIRequestable {
    public typealias Response = DSGradingPeriodSetResponse

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body) {
        self.body = body
        self.path = "accounts/self/grading_period_sets"
    }
}

extension CreateDSGradingPeriodSetRequest {
    public struct RequestedDSGradingPeriodSet: Encodable {
        let title: String

        public init(title: String) {
            self.title = title
        }
    }

    public struct Body: Encodable {
        let enrollment_term_ids: [String]
        let grading_period_set: RequestedDSGradingPeriodSet
    }
}

public struct CreateDSGradingPeriodSetPatchRequest: APIRequestable {
    public typealias Response = DSGradingPeriodSetPatchResponse

    public let method = APIMethod.patch
    public var path: String
    public let body: Body?

    public init(gradingPeriodSet: DSGradingPeriodSet, body: Body) {
        self.body = body
        self.path = "grading_period_sets/\(gradingPeriodSet.id)/grading_periods/batch_update"
    }
}

extension CreateDSGradingPeriodSetPatchRequest {
    public struct RequestedDSGradingPeriod: Encodable {
        let title: String
        let start_date: Date
        let end_date: Date
        let close_date: Date

        public init(
            title: String,
            startDate: Date,
            endDate: Date,
            closeDate: Date
        ) {
            self.title = title
            self.start_date = startDate
            self.end_date = endDate
            self.close_date = closeDate
        }
    }

    public struct Body: Encodable {
        let grading_periods: [RequestedDSGradingPeriod]
    }
}
