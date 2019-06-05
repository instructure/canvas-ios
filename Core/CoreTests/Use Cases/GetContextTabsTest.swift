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

class GetContextTabsTest: CoreTestCase {

    let context = ContextModel(.group, id: "1")

    func testCacheKey() {
        let useCase = GetContextTabs(context: context)

        XCTAssertEqual("get-group_1-tabs", useCase.cacheKey)
    }

    func testScopeSort() {
        Tab.make(from: .make(label: "3", position: 3))
        Tab.make(from: .make(label: "1", position: 1))
        Tab.make(from: .make(label: "2", position: 2))

        let useCase = GetContextTabs(context: context)

        let tabs: [Tab] = databaseClient.fetch(useCase.scope.predicate, sortDescriptors: useCase.scope.order)

        XCTAssertEqual(tabs.first?.label, "1")
        XCTAssertEqual(tabs.last?.label, "3")
    }

    func testItCreatesTabs() {
        let groupTab = APITab.make(html_url: URL(string: "https://twilson.instructure.com/groups/16")!)
        let getContextTabs = GetContextTabs(context: context)
        getContextTabs.write(response: [groupTab], urlResponse: nil, to: databaseClient)

        let tabs: [Tab] = databaseClient.fetch()
        XCTAssertEqual(tabs.count, 1)
        XCTAssertEqual(tabs.first?.label, "Home")
        XCTAssertEqual(tabs.first?.htmlURL.absoluteString, "https://twilson.instructure.com/groups/16")
    }

    func testItCreatesTabsMultipleRequests() {
        let context1 = ContextModel(.group, id: Group.make(from: .make(id: "1")).id)
        let context2 = ContextModel(.group, id: Group.make(from: .make(id: "2")).id)

        let groupTab1 = APITab.make(id: "home", html_url: URL(string: "https://twilson.instructure.com/groups/1")!)
        let groupTab2 = APITab.make(id: "assignments", html_url: URL(string: "https://twilson.instructure.com/groups/2")!)

        let getContextTabs1 = GetContextTabs(context: context1)
        getContextTabs1.write(response: [groupTab1], urlResponse: nil, to: databaseClient)

        let getContextTabs2 = GetContextTabs(context: context2)
        getContextTabs2.write(response: [groupTab2], urlResponse: nil, to: databaseClient)

        let tabs: [Tab] = databaseClient.fetch()
        let home = tabs.filter { $0.id == "home" }.first
        let assignments = tabs.filter { $0.id == "assignments" }.first
        XCTAssertEqual(tabs.count, 2)
        XCTAssertEqual(home?.htmlURL.absoluteString, "https://twilson.instructure.com/groups/1")
        XCTAssertEqual(assignments?.htmlURL.absoluteString, "https://twilson.instructure.com/groups/2")
    }
}
