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
    override var baseEnrollment: APIEnrollment {
        .make(
            type: "ObserverEnrollment",
            role: "ObserverEnrollment"
        )
    }

    override func mockBaseRequests() {
        mockData(GetWebSessionRequest(to: URL(string: "https://canvas.instructure.com/users/self"))) // cookie keepalive
        mockEncodableRequest([
            "users/self/enrollments",
            "?include[]=avatar_url&include[]=observed_users",
            "&per_page=99",
            "&role[]=ObserverEnrollment",
            "&state[]=active&state[]=completed&state[]=creation_pending",
            "&state[]=current_and_future&state[]=invited",
        ].joined(), value: [baseEnrollment])
        mockData(GetContextPermissionsRequest(context: ContextModel(.account, id: "self"), permissions: [.becomeUser]), value: .make())
    }
}
