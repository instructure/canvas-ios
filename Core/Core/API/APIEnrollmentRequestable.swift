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

// https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.create
struct PostEnrollmentRequest: APIRequestable {
    typealias Response = APIEnrollment
    struct Body: Codable, Equatable {
        struct Enrollment: Codable, Equatable {
            let user_id: String
            let type: String
            let enrollment_state: EnrollmentState
        }

        let enrollment: Enrollment
    }

    let courseID: String

    let body: Body?
    let method = APIMethod.post
    var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/enrollments"
    }
}

// https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.index
struct GetEnrollmentsRequest: APIRequestable {
    typealias Response = [APIEnrollment]
    enum Include: String {
        case observed_users, avatar_url
    }

    let context: Context
    let userID: String?
    let gradingPeriodID: String?
    let includes: [Include]

    init(context: Context, userID: String?, gradingPeriodID: String?, includes: [Include] = []) {
        self.context = context
        self.userID = userID
        self.gradingPeriodID = gradingPeriodID
        self.includes = includes
    }

    var path: String {
        return "\(context.pathComponent)/enrollments"
    }
    var query: [APIQueryItem] {
        var query: [APIQueryItem] = [
            .include(includes.map { $0.rawValue }),
        ]
        if let userID = userID {
            query.append(.value("user_id", userID))
        }
        if let gradingPeriodID = gradingPeriodID {
            query.append(.value("grading_period_id", gradingPeriodID))
        }
        return query
    }
}
