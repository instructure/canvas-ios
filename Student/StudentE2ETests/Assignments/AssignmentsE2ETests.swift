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
@testable import TestsFoundation

class AssignmentsE2ETests: CoreUITestCase {
    func testCourseGradeIsCorrect() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.grades.tap()

        app.find(labelContaining: "72.73%").waitToExist()
    }

    func testViewAssignmentAndPreviewAttachment() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.grades.tap()

        GradeList.cell(assignmentID: "1831").tap()

        AssignmentDetails.description("This is assignment one.").waitToExist()
        app.swipeUp()
        AssignmentDetails.link("run.jpg").tap()
        XCTAssertEqual(FileDetails.imageView.label(), "run.jpg")
    }

    func testLaunchQuizzesNextAssignment() {
        Dashboard.courseCard(id: "399").tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "3181").tap()
        AssignmentDetails.submitAssignmentButton.tap()
        QuizzesNext.text("Read-only Quiz").waitToExist()
        QuizzesNext.beginButton.waitToExist()
        QuizzesNext.doneButton.tap()
        QuizzesNext.doneButton.waitToVanish()
    }
}
