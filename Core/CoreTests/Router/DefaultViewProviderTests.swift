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

class DefaultViewProviderTests: CoreTestCase {

    func testDefaultViewPresentation() {
        let testee = MockDefaultViewProviderViewController()
        let splitView = UISplitViewController()
        splitView.viewControllers = [UINavigationController(rootViewController: testee), UIViewController()]

        testee.showDefaultDetailView()
        XCTAssertTrue(router.lastRoutedTo("/empty"))
    }

    func testPresentationFromDetailViewDoesNothing() {
        let testee = MockDefaultViewProviderViewController()
        let splitView = UISplitViewController()
        splitView.viewControllers = [UIViewController(), UINavigationController(rootViewController: testee)]

        testee.showDefaultDetailView()
        XCTAssertTrue(router.calls.isEmpty)
    }

    func testPresentationOutsideSplitViewDoesNothing() {
        let testee = MockDefaultViewProviderViewController()

        testee.showDefaultDetailView()
        XCTAssertTrue(router.calls.isEmpty)
    }
}

class MockDefaultViewProviderViewController: UIViewController, DefaultViewProvider {
    var defaultViewRoute: String? {
        get { "/empty" }
        set {}
    }
}
