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

class SubmissionsE2ETests: CoreUITestCase {
    func testSubmissionsE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .assignments).hit()
        AssignmentsHelper.assignmentButton(assignmentId: "1831").hit()
        XCTAssertTrue(app.find(labelContaining: "This is assignment one.").waitUntil(.visible).isVisible)

        AssignmentsHelper.Details.viewAllSubmissionsButton.hit()
        pullToRefresh()
        app.find(labelContaining: "Filter").hit()
        app.find(labelContaining: "Graded").hit()
        app.find(label: "Done").hit()
        XCTAssertTrue(app.find(labelContaining: "Student One").waitUntil(.visible).isVisible)

        app.find(labelContaining: "Filter").hit()
        app.find(labelContaining: "Needs Grading").hit()
        app.find(label: "Done").hit()
        XCTAssertTrue(app.find(labelContaining: "No Submissions").waitUntil(.visible).isVisible)

        app.find(labelContaining: "Filter").hit()
        app.find(labelContaining: "Not Submitted").hit()
        app.find(label: "Done").hit()
        pullToRefresh()
        XCTAssertTrue(app.find(labelContaining: "Test Student").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "Student Two").waitUntil(.visible).isVisible)
        XCTAssertFalse(app.find(labelContaining: "Student One").waitUntil(.vanish).isVisible)

        // On the submissions list screen, the navbar's back button is somehow different
        app.find(labelContaining: "Assignment Details, Assignments").hit()
        AssignmentsHelper.backButton.hit()
        AssignmentsHelper.assignmentButton(assignmentId: "2075").hit()
        XCTAssertTrue(app.find(labelContaining: "This assignment is for testing module navigation").waitUntil(.visible).isVisible)

        AssignmentsHelper.Details.viewAllSubmissionsButton.hit()
        app.find(labelContaining: "Filter").hit()
        app.find(labelContaining: "Graded").hit()
        app.find(label: "Done").hit()
        XCTAssertTrue(app.find(labelContaining: "No Submissions").waitUntil(.visible).isVisible)

        app.find(labelContaining: "Filter").hit()
        app.find(labelContaining: "Needs Grading").hit()
        app.find(label: "Done").hit()
        XCTAssertTrue(app.find(labelContaining: "No Submissions").waitUntil(.visible).isVisible)

        app.find(labelContaining: "Filter").hit()
        app.find(labelContaining: "Not Submitted").hit()
        app.find(label: "Done").hit()
        pullToRefresh()
        XCTAssertTrue(app.find(labelContaining: "Test Student").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "Student Two").waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "Student One").waitUntil(.visible).isVisible)
    }
}
