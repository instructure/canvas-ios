//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core

class GetContextPermissionsTests: CoreTestCase {
    func testItCreatesPermissions() {
        let response = APIPermissions.make(become_user: true)

        let context = Context(.account, id: "1")

        let getContextPermissions = GetContextPermissions(context: context, permissions: [.becomeUser])
        getContextPermissions.write(response: response, urlResponse: nil, to: databaseClient)

        let permissions: Permissions = databaseClient.fetch().first!
        XCTAssertEqual(permissions.context, context.canvasContextID)
        XCTAssertTrue(permissions.becomeUser)
        XCTAssertFalse(permissions.manageSis)
    }

    func testItUpdatesPermissions() {
        let permissions = Permissions.make(from: .make(become_user: true))
        let response = APIPermissions.make(become_user: false)

        let context = Context(.account, id: "1")

        let getContextPermissions = GetContextPermissions(context: context, permissions: [.becomeUser])
        getContextPermissions.write(response: response, urlResponse: nil, to: databaseClient)

        databaseClient.refresh()
        XCTAssertFalse(permissions.becomeUser)
    }

    func testCacheKey() {
        let getContextPermissions = GetContextPermissions(context: .account("1"), permissions: [.becomeUser, .manageSis])
        XCTAssertEqual(getContextPermissions.cacheKey, "get-account_1-permissions-become_user,manage_sis")
    }

    func testScope() {
        let model = Permissions.make(from: .make(become_user: true))
        let getContextPermissions = GetContextPermissions(context: .account("1"), permissions: [.becomeUser])

        let permissions: Permissions = databaseClient.fetch(getContextPermissions.scope.predicate, sortDescriptors: getContextPermissions.scope.order).first!
        XCTAssertEqual(permissions, model)
    }
}
