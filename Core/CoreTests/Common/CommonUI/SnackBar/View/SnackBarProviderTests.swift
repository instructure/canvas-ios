//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Core
import UIKit
import XCTest
import SwiftUI

class SnackBarProviderTests: XCTestCase {

    func testFindsSnackBarProviderTabbar() {
        let testee = UIViewController()
        let tabBarController = SnackBarProviderTabBar()
        tabBarController.viewControllers = [testee]

        // WHEN
        let snackBarViewModel = testee.findSnackBarViewModel()

        // THEN
        XCTAssertEqual(snackBarViewModel, tabBarController.snackBarViewModel)
    }

    func testAddSnackBarToTabBarController() {
        let testee = SnackBarProviderTabBar()
        XCTAssertEqual(testee.view.subviews.count, 2)

        // WHEN
        testee.addSnackBar()

        // THEN
        XCTAssertEqual(testee.view.subviews.count, 3)
        XCTAssertTrue(testee.view.subviews.last is _UIHostingView<CoreHostingBaseView<SnackWrapper>>)
    }
}

class SnackBarProviderTabBar: UITabBarController, SnackBarProvider {
    var snackBarViewModel = SnackBarViewModel()
}
