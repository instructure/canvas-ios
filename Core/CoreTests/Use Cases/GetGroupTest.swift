//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class GetGroupTest: CoreTestCase {
    func testItCreatesGroup() {
        let response = APIGroup.make()

        let getGroup = GetGroup(groupID: "1", env: environment)
        try! getGroup.write(response: response, urlResponse: nil, to: databaseClient)

        let groups: [Group] = databaseClient.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first?.id, response.id.value)
        XCTAssertEqual(groups.first?.name, response.name)
    }

    func testItUpdatesGroup() {
        let group = Group.make(["id": "1", "name": "Old Name"])
        let response = APIGroup.make(["id": "1", "name": "New Name"])

        let getGroup = GetGroup(groupID: "1", env: environment)
        try! getGroup.write(response: response, urlResponse: nil, to: databaseClient)
        databaseClient.refresh()
        XCTAssertEqual(group.name, "New Name")
    }

    func testCacheKey() {
        let getGroup = GetGroup(groupID: "1", env: environment)
        XCTAssertEqual("get-group-1", getGroup.cacheKey)
    }

    func testScope() {
        let group = Group.make(["id": "1", "name": "Old Name"])
        let getGroup = GetGroup(groupID: "1", env: environment)

        let groups: [Group] = databaseClient.fetch(predicate: getGroup.scope.predicate, sortDescriptors: getGroup.scope.order)

        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups.first, group)
    }
}
