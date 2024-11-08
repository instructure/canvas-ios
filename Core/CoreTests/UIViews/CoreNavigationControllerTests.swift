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
import SwiftUI
import XCTest

class CoreNavigationControllerTests: CoreTestCase {

    func testPushNavigationControllerNotCrashes() {
        let testee = CoreNavigationController()
        testee.developerAnalytics.handler = developerAnalytics

        // Pushing a subclass of UINavigationController to check if our guard works for subclasses as well
        let navigationController = CoreNavigationController(rootViewController: EmptyViewController())
        navigationController.pushViewController(CoreHostingController(SwiftUI.EmptyView()), animated: false)

        // WHEN
        XCTAssertNoThrow(testee.pushViewController(navigationController, animated: false))

        // THEN
        XCTAssertEqual(
            developerAnalytics.lastErrorName,
            "Pushing nav controller was prevented"
        )
        XCTAssertEqual(
            developerAnalytics.lastErrorReason,
            "CoreNavigationController [EmptyViewController, EmptyView]"
        )
        XCTAssertEqual(
            developerAnalytics.totalErrorCount,
            1
        )
    }
}
