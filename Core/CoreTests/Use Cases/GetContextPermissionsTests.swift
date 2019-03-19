//
// Copyright (C) 2019-present Instructure, Inc.
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

import XCTest
@testable import Core

class GetContextPermissionsTests: CoreTestCase {
    func testItCreatesPermissions() {
        let response = APIPermissions.make(["become_user": true ])

        let context = ContextModel(.account, id: "1")

        let getContextPermissions = GetContextPermissions(context: context, permissions: [.becomeUser])
        try! getContextPermissions.write(response: response, urlResponse: nil, to: databaseClient)

        let permissions: Permissions = databaseClient.fetch(predicate: nil, sortDescriptors: nil).first!
        XCTAssertEqual(permissions.context, context.canvasContextID)
        XCTAssertTrue(permissions.becomeUser)
        XCTAssertFalse(permissions.manageSis)
    }

    func testItUpdatesPermissions() {
        let permissions = Permissions.make(["becomeUser": true])
        let response = APIPermissions.make(["become_user": false])

        let context = ContextModel(.account, id: "1")

        let getContextPermissions = GetContextPermissions(context: context, permissions: [.becomeUser])
        try! getContextPermissions.write(response: response, urlResponse: nil, to: databaseClient)

        databaseClient.refresh()
        XCTAssertFalse(permissions.becomeUser)
    }

    func testCacheKey() {
        let getContextPermissions = GetContextPermissions(context: ContextModel(.account, id: "1"), permissions: [.becomeUser, .manageSis])
        XCTAssertEqual(getContextPermissions.cacheKey, "get-account_1-permissions-become_user,manage_sis")
    }

    func testScope() {
        let model = Permissions.make(["becomeUser": true])
        let getContextPermissions = GetContextPermissions(context: ContextModel(.account, id: "1"), permissions: [.becomeUser])

        let permissions: Permissions = databaseClient.fetch(predicate: getContextPermissions.scope.predicate, sortDescriptors: getContextPermissions.scope.order).first!
        XCTAssertEqual(permissions, model)
    }
}
