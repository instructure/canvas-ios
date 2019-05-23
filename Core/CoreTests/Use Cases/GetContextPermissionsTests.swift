//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
@testable import Core

class GetContextPermissionsTests: CoreTestCase {
    func testItCreatesPermissions() {
        let response = APIPermissions.make(become_user: true)

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
        let response = APIPermissions.make(become_user: false)

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
