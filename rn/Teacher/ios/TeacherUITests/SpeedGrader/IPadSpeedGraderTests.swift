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

class IPadSpeedGraderTests: MiniCanvasUITestCase {
    func testSpeedGrader() {
        XCUIDevice.shared.orientation = .landscapeLeft
        SpringBoard.shared.setupSplitScreenWithSafariOnRight()
        SpringBoard.shared.moveSplit(toFraction: 0.5)

        let students = mocked.students

        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: firstAssignment.id).tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        app.find(labelContaining: students[0].name).waitToExist()
        app.find(labelContaining: students[1].name).waitToExist()
        app.find(labelContaining: students[2].name).waitToExist()
        SubmissionsList.row(contextID: students[1].id.value).tap()
        SpeedGrader.dismissTutorial()
        SpeedGrader.doneButton.waitToExist()
        SpeedGrader.userName(userID: students[1].id.value).waitToExist()
        XCTAssertFalse(SpeedGrader.userName(userID: students[0].id.value).isVisible)
        XCTAssertTrue(SpeedGrader.userName(userID: students[1].id.value).isVisible)
        XCTAssertFalse(SpeedGrader.userName(userID: students[2].id.value).isVisible)
    }
}
