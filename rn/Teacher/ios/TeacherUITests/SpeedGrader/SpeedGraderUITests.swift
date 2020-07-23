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

class SpeedGraderUITests: MiniCanvasUITestCase {
    func testNavigateToSpeedGrader() {
        Dashboard.courseCard(id: firstCourse.id).tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: firstAssignment.id).tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        SubmissionsList.row(contextID: mocked.students[1].id.value).tap()
        SpeedGrader.dismissTutorial()
    }
}
