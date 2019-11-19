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

class AssignmentPostPolicyTests: TeacherUITestCase {
    func testPostPolicySettings() {
        let courseID = "1277"
        let assignmentID = "9298"
        let sectionID = "U2VjdGlvbi05MjU="

        show("/courses/\(courseID)/assignments/\(assignmentID)/submissions")

        SubmissionsList.postpolicy.tap()

        func checkPost() {
            XCTAssertEqual(PostPolicy.postToValue.label(), "Everyone")
            PostPolicy.postTo.tap()
            PostToSelection.graded.tap()
            app.find(label: "Back").tap()

            XCTAssertEqual(PostPolicy.postToValue.label(), "Graded")

            PostPolicy.togglePostToSections.tap()

            PostPolicy.postToSectionToggle(id: sectionID).tap()
            PostPolicy.postGradesButton.tap()

            SubmissionsList.postpolicy.waitToExist()
        }

        func checkHide() {
            PostPolicy.toggleHideGradeSections.tap()
            let hideSectionToggle = PostPolicy.hideSectionToggle(id: sectionID)
            hideSectionToggle.tap()
            PostPolicy.hideGradesButton.tap()
            SubmissionsList.postpolicy.waitToExist()
        }

        let waitForAPI: UInt32 = 10

        let timeout = Date() + 30
        while Date() < timeout {
            if PostPolicy.allGradesPosted.exists {
                app.find(id: "PostSettings.hideMenuItem").tap()
                checkHide()
                sleep(waitForAPI)
                SubmissionsList.postpolicy.tap()
                checkPost()
                return
            } else if PostPolicy.postTo.exists {
                checkPost()
                sleep(waitForAPI)
                SubmissionsList.postpolicy.tap()
                app.find(id: "PostSettings.hideMenuItem").tap()
                checkHide()
                return
            }
            sleep(1)
        }
        XCTFail("timeout")
    }
}
