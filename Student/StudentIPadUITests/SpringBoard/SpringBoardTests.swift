//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import TestsFoundation
@testable import CoreUITests

class SpringBoardTests: CoreUITestCase {
    func testMultitaskingSetup() {
        XCUIDevice.shared.orientation = .landscapeLeft
        SpringBoard.shared.setupSplitScreenWithSafariOnRight()

        sleep(1)
        XCTAssertEqual(app.find(type: .window).frame().width, 507)

        SpringBoard.shared.moveSplit(toFraction: 0.25)
        sleep(1)
        XCTAssertEqual(app.find(type: .window).frame().width, 320)

        SpringBoard.shared.moveSplit(toFraction: 0.75)
        sleep(1)
        XCTAssertEqual(app.find(type: .window).frame().width, 694)

        SpringBoard.shared.moveSplit(toFraction: 0.5)
        sleep(1)
        XCTAssertEqual(app.find(type: .window).frame().width, 507)
    }
}
