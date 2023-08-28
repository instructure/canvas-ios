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

import TestsFoundation

class AssignmentsE2ETests: CoreUITestCase {
    func testAssignmentsE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .assignments).hit()
        AssignmentsHelper.assignmentButton(assignmentId: "1831").hit()
        XCTAssertTrue(app.find(labelContaining: "This is assignment one.").waitUntil(.visible).isVisible)
        AssignmentsHelper.backButton.hit()

        // AssignmentsList.assignment(id: "261986").tap() doesn't work so we scroll to the cell
        // and tap on the screen with absolute screen coordinates.
        app.swipeUp()
        app.windows.firstMatch.tapAt(CGPoint(x: 10, y: 580))

        XCTAssertTrue(app.find(labelContaining: "10 pts").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "Needs Grading").waitUntil(.visible).isVisible)
        AssignmentsHelper.backButton.hit()
        AssignmentsHelper.backButton.hit()
        AssignmentsHelper.backButton.hit()
        XCTAssertTrue(DashboardHelper.courseCard(courseId: "263").waitUntil(.visible).isVisible)
    }
}
