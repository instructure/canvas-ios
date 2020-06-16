//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import XCTest
import TestsFoundation
@testable import Core

class ParentUITestCase: CoreUITestCase {
    override var user: UITestUser? { nil }

    override var baseEnrollment: APIEnrollment {
        .make(
            type: "ObserverEnrollment",
            role: "ObserverEnrollment",
            observed_user: APIUser.make()
        )
    }

    override func mockBaseRequests() {
        mockData(GetBrandVariablesRequest(), value: APIBrandVariables.make())
        mockData(GetUserRequest(userID: "self"), value: APIUser.make())
        mockData(GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/users/self"))) // cookie keepalive
        for paginated in [true, false] {
            mockEncodableRequest([
                "users/self/enrollments",
                "?include[]=avatar_url&include[]=observed_users",
                paginated ? "&per_page=100" : "",
                "&role[]=ObserverEnrollment",
                "&state[]=active&state[]=completed&state[]=creation_pending",
                "&state[]=current_and_future&state[]=invited",
                ].joined(), value: [baseEnrollment])
        }
        mockData(GetContextPermissionsRequest(context: .account("self"), permissions: [.becomeUser]), value: .make())
        mock(courses: [.make(enrollments: [baseEnrollment])])
        mockData(GetConversationsUnreadCountRequest(), value: .init(unread_count: 0))
        mockData(GetAccountHelpLinksRequest(), value: .make())
        mockData(GetUserSettingsRequest(userID: "self"), value: .make())
        mockData(GetUserProfileRequest(userID: "self"), value: .make())
        mockData(GetGlobalNavExternalToolsRequest(), value: [])
        mockEncodableRequest("users/self/observer_alerts/1?per_page=100", value: [String]())
    }
}
