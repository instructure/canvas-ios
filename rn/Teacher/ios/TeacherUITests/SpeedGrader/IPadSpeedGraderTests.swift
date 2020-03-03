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

import XCTest
import TestsFoundation
@testable import Core
@testable import CoreUITests

class IPadSpeedGraderTests: CoreUITestCase {
    let mockHelper = SpeedGraderUIMocks()

    func testSpeedGrader() {
        mockHelper.mock(for: self)
        XCUIDevice.shared.orientation = .landscapeLeft
        logIn()
        SpringBoard.shared.setupSplitScreenWithSafariOnRight()
        SpringBoard.shared.moveSplit(toFraction: 0.5)
        Dashboard.courseCard(id: "1").tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "1").tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        app.find(labelContaining: "User 1").waitToExist()
        app.find(labelContaining: "User 2").waitToExist()
        app.find(labelContaining: "User 3").waitToExist()
        SubmissionsList.row(contextID: "2").tap()
        SpeedGrader.dismissTutorial()
        SpeedGrader.doneButton.waitToExist()
        SpeedGrader.userName(userID: "2").waitToExist()
        XCTAssertTrue(SpeedGrader.userName(userID: "2").isVisible)
        XCTAssertFalse(SpeedGrader.userName(userID: "1").isVisible)
        XCTAssertFalse(SpeedGrader.userName(userID: "3").isVisible)
    }

}
