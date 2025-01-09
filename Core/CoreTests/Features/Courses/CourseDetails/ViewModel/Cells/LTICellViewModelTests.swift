//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

@testable import Core
import XCTest

class LTICellViewModelTests: CoreTestCase {

    func testProperties() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        let testee = LTICellViewModel(tab: tab, course: course, url: URL(string: "/ltitool")!)
        XCTAssertEqual(testee.iconImage, tab.icon)
        XCTAssertEqual(testee.label, "Home")
        XCTAssertEqual(testee.subtitle, nil)
        XCTAssertEqual(testee.accessoryIconType, .externalLink)
        XCTAssertEqual(testee.tabID, "home")
    }

    func testLTILaunch() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        let testee = LTICellViewModel(tab: tab, course: course, url: URL(string: "/ltitool")!)
        testee.selected(router: router, viewController: WeakViewController(UIViewController()))
        // we can't mock LTITools so we just check if anything goes horribly wrong
    }
}
