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

class GenericCellViewModelTests: CoreTestCase {

    func testPagesRouting() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(id: "pages"), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        let testee = GenericCellViewModel(tab: tab, course: course, selectedCallback: {})
        testee.selected(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(router.lastRoutedTo(URL(string: "/courses/1/pages")!))
    }

    func testCollaborationsRouting() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(id: "collaborations", full_url: URL(string: "/collab")), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        let testee = GenericCellViewModel(tab: tab, course: course, selectedCallback: {})
        testee.selected(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(router.lastRoutedTo(URL(string: "/collab")!))
    }

    func testConferencesRouting() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(id: "conferences", full_url: URL(string: "/conf")), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        let testee = GenericCellViewModel(tab: tab, course: course, selectedCallback: {})
        testee.selected(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(router.lastRoutedTo(URL(string: "/conf")!))
    }

    func testOutcomesRouting() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(id: "outcomes", full_url: URL(string: "/outcomes")), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        let testee = GenericCellViewModel(tab: tab, course: course, selectedCallback: {})
        testee.selected(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(router.lastRoutedTo(URL(string: "/outcomes")!))
    }

    func testDefaultRouting() {
        let tab: Tab = databaseClient.insert()
        tab.save(.make(id: "custom_tab5", html_url: URL(string: "/website")!), in: databaseClient, context: .course("1"))
        let course = Course.save(.make(), in: databaseClient)

        let testee = GenericCellViewModel(tab: tab, course: course, selectedCallback: {})
        testee.selected(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertTrue(router.lastRoutedTo(URL(string: "/website")!))
    }
}
