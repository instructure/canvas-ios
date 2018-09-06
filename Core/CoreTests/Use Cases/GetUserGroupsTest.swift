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
import XCTest
@testable import Core

class GetUserGroupsTest: CoreTestCase {
    func testItSavesUserGroups() {
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        let group = APIGroup.make(["id": "1", "name": "Group One", "members_count": 2])
        api.mock(request, value: [group])

        let getUserGroups = GetUserGroups(api: api, database: db)
        addOperationAndWait(getUserGroups)

        let groups: [Group] = db.fetch()
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, "1")
        XCTAssertEqual(groups.first?.member, true)
    }

    func testItDeletesOldUserGroups() {
        let old = group(["member": true])
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        api.mock(request, value: [])

        let getUserGroups = GetUserGroups(api: api, database: db)
        addOperationAndWait(getUserGroups)

        let groups: [Group] = db.fetch()
        XCTAssertFalse(groups.contains(old))
    }

    func testItDoesNotDeleteNonUserGroups() {
        let notMember = group(["member": false])
        let request = GetGroupsRequest(context: ContextModel.currentUser)
        api.mock(request, value: [])

        let getUserGroups = GetUserGroups(api: api, database: db)
        addOperationAndWait(getUserGroups)

        let groups: [Group] = db.fetch()
        XCTAssert(groups.contains(notMember))
    }
}
