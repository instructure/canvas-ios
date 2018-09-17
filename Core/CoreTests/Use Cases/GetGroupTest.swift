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

class GetGroupTest: CoreTestCase {
    func testItCreatesGroup() {
        let request = GetGroupRequest(id: "1")
        let response = APIGroup.make()
        api.mock(request, value: response)

        let getGroup = GetGroup(groupID: "1", api: api, database: db)
        addOperationAndWait(getGroup)

        let groups: [Group] = db.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, response.id.value)
        XCTAssertEqual(groups.first?.name, response.name)
    }

    func testItUpdatesGroup() {
        let group = self.group(["id": "1", "name": "Old Name"])
        let request = GetGroupRequest(id: "1")
        let response = APIGroup.make(["id": "1", "name": "New Name"])
        api.mock(request, value: response)

        let getGroup = GetGroup(groupID: "1", api: api, database: db)
        addOperationAndWait(getGroup)
        db.refresh()
        XCTAssertEqual(group.name, "New Name")
    }
}
