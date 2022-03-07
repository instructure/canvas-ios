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

class SubmissionsE2ETests: CoreUITestCase {
    func testSubmissionsE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "1831").tap()
        AssignmentDetails.description("This is assignment one.").waitToExist()

        AssignmentDetails.viewAllSubmissionsButton.tap()
        pullToRefresh()
        app.find(labelContaining: "Filter").tap()
        app.find(labelContaining: "Graded").tap()
        app.find(label: "Done").tap()
        app.find(labelContaining: "Student One").waitToExist()

        app.find(labelContaining: "Filter").tap()
        app.find(labelContaining: "Needs Grading").tap()
        app.find(label: "Done").tap()
        app.find(labelContaining: "No Submissions").waitToExist()

        app.find(labelContaining: "Filter").tap()
        app.find(labelContaining: "Not Submitted").tap()
        app.find(label: "Done").tap()
        pullToRefresh()
        app.find(labelContaining: "Test Student").waitToExist()
        app.find(labelContaining: "Student Two").waitToExist()
        app.find(labelContaining: "Student One").waitToVanish()

        // On the submissions list screen, the navbar's back button is somehow different
        app.find(labelContaining: "Assignment Details, Assignments").tap()
        NavBar.backButton.tap()
        AssignmentsList.assignment(id: "2075").tap()
        AssignmentDetails.description("This assignment is for testing module navigation").waitToExist()

        AssignmentDetails.viewAllSubmissionsButton.tap()
        app.find(labelContaining: "Filter").tap()
        app.find(labelContaining: "Graded").tap()
        app.find(label: "Done").tap()
        app.find(labelContaining: "No Submissions").waitToExist()

        app.find(labelContaining: "Filter").tap()
        app.find(labelContaining: "Needs Grading").tap()
        app.find(label: "Done").tap()
        app.find(labelContaining: "No Submissions").waitToExist()

        app.find(labelContaining: "Filter").tap()
        app.find(labelContaining: "Not Submitted").tap()
        app.find(label: "Done").tap()
        pullToRefresh()
        app.find(labelContaining: "Test Student").waitToExist()
        app.find(labelContaining: "Student Two").waitToExist()
        app.find(labelContaining: "Student One").waitToExist()
    }
}
