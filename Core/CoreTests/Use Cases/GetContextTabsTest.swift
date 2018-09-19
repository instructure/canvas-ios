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

class GetContextTabsTest: CoreTestCase {

    let context = ContextModel(.group, id: "1")
    lazy var request: GetTabsRequest = { [weak self] in
        return GetTabsRequest(context: self!.context)
    }()

    func testItCreatesTabs() {
        let groupTab = APITab.make(["id": "1", "label": "Home"])
        api.mock(request, value: [groupTab], response: nil, error: nil)

        let getContextTabs = GetContextTabs(context: context, api: api, database: db)
        addOperationAndWait(getContextTabs)

        let tabs: [Tab] = db.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(tabs.count, 1)
        XCTAssertEqual(tabs.first?.id, "1")
        XCTAssertEqual(tabs.first?.label, "Home")
    }

    func testItDeletesTabsThatNoLongerExist() {
        let tab = self.tab()
        api.mock(request, value: [], response: nil, error: nil)

        let getContextTabs = GetContextTabs(context: context, api: api, database: db)
        addOperationAndWait(getContextTabs)

        let tabs: [Tab] = db.fetch()
        XCTAssertFalse(tabs.contains(tab))
    }
}
