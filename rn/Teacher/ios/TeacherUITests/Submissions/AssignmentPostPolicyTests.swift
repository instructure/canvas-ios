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

class AssignmentPostPolicyTests: TeacherUITestCase {
    func testPostPolicySettings() {
        let courseID = "263"
        let assignmentID = "5431"
        show("/courses/\(courseID)/assignments/\(assignmentID)/submissions")

        SubmissionsList.postpolicy.waitToExist()
        SubmissionsList.postpolicy.tap()

        //  POST
        var predicate = NSPredicate(format: "label CONTAINS[c] %@", "GRADE CURRENTLY HIDDEN")
        _ = app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 0.5)

        XCTAssertEqual(PostPolicy.postToValue.label, "Everyone")
        PostPolicy.postTo.tap()

        let cells = app.cells.containing(NSPredicate(format: "label CONTAINS %@", "Graded"))

        let gradedCell = cells.firstMatch
        gradedCell.tap()
        app.find(label: "Back").tap()

        XCTAssertEqual(PostPolicy.postToValue.label, "Graded")

        PostPolicy.togglePostToSections.tap()

        let postToSectionToggle = PostPolicy.postToSectionToggle(id: "U2VjdGlvbi0yMjE=")
        postToSectionToggle.waitToExist()
        postToSectionToggle.tap()
        PostPolicy.postGradesButton.tap()

        SubmissionsList.postpolicy.waitToExist()
        SubmissionsList.postpolicy.tap()

        app.find(label: "All grades are currently posted.").waitToExist()
        app.swipeLeft()

        //  HIDE
        predicate = NSPredicate(format: "label CONTAINS[c] %@", "GRADE CURRENTLY POSTED")
        _ = app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 0.5)

        PostPolicy.toggleHideGradeSections.tap()
        let hideSectionToggle = PostPolicy.hideSectionToggle(id: "U2VjdGlvbi0yMjE=")
        hideSectionToggle.waitToExist()
        hideSectionToggle.tap()
        PostPolicy.hideGradesButton.tap()
        SubmissionsList.postpolicy.waitToExist()
    }

}
