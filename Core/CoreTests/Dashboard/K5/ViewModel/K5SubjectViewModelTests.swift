//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5SubjectViewModelTests: CoreTestCase {

    var courseId: String!
    var context: Context!

    override func setUp() {
        super.setUp()
        courseId = "1"
        context = Context(.course, id: courseId)
    }

    func testTopBarViewResources() {
        Tab.make(from: .make(id: "home", type: .internal), context: context)
        Tab.make(from: .make(id: "context_external_tool_test", type: .external), context: context)
        let testee = K5SubjectViewModel(context: context)
        guard let topBarItems = testee.topBarViewModel?.items else { XCTFail(); return }
        XCTAssertEqual(topBarItems.count, 2)
        XCTAssertEqual(topBarItems.filter({ $0.id == "resources" }).count, 1)
    }

    func testPageUrl() {
        let pageId = "schedule"
        let url = K5SubjectViewModel(context: context).pageUrl(for: pageId)
        XCTAssertEqual(url?.path, "/courses/" + courseId)
        XCTAssertEqual(url?.query, "embed=true")
        XCTAssertEqual(url?.fragment, "\(pageId)")
    }
}
