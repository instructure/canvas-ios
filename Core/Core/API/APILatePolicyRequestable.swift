//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

struct PostLatePolicyRequest: APIRequestable {
    struct Response: Codable, Equatable {
        let late_policy: APILatePolicy
    }
    struct Body: Codable, Equatable {
        struct LatePolicy: Codable, Equatable {
            let late_submission_deduction_enabled: Bool?
            let late_submission_deduction: Double?
            let late_submission_interval: LatePolicyInterval
        }

        let late_policy: LatePolicy
    }

    let courseID: String

    let body: Body?
    let method = APIMethod.post
    var path: String {
        let context = ContextModel(.course, id: courseID)
        return "\(context.pathComponent)/late_policy"
    }
}
