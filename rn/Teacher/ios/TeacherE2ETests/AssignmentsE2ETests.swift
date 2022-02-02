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
import TestsFoundation

class AssignmentsE2ETests: CoreUITestCase {
    func testAssignmentsE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "1831").tap()
        AssignmentDetails.description("This is assignment one.").waitToExist()
        NavBar.backButton.tap()

        // AssignmentsList.assignment(id: "261986").tap() doesn't work so we scroll to the cell
        // and tap on the screen with absolute screen coordinates.
        app.swipeUp()
        app.windows.firstElement.tapAt(CGPoint(x: 10, y: 580))

        app.find(labelContaining: "10 pts").waitToExist()
        app.find(labelContaining: "Needs Grading").waitToExist()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        NavBar.backButton.tap()
        Dashboard.courseCard(id: "263").waitToExist()
    }
}
