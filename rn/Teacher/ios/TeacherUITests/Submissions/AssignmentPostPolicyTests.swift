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

class AssignmentPostPolicyTests: CoreUITestCase {
    func testPostPolicySettings() {
        mockBaseRequests()
        mock(assignment: .make())

        show("/courses/1/assignments/1/submissions")

        mockGraphQL(GetAssignmentPostPolicyInfoRequest(courseID: "1", assignmentID: "1"),
                    value: .make())

        mockGraphQL(operationName: "SubmissionList", SubmissionListFixture.submissionList)

        SubmissionsList.postpolicy.tap()

        XCTAssertEqual(PostPolicy.postToValue.label(), "Everyone")
        PostPolicy.postTo.tap()
        PostToSelection.graded.tap()
        app.find(label: "Back").tap()

        XCTAssertEqual(PostPolicy.postToValue.label(), "Graded")

        PostPolicy.togglePostToSections.toggleOn()
        PostPolicy.postToSectionToggle(id: "1").toggleOn()

        mockGraphQL(operationName: PostAssignmentGradesPostPolicyRequest.operationName, [
            "data": [ "postAssignmentGradesForSections": [ "assignment": [ "id": "1" ] ] ],
        ])
        mockGraphQL(GetAssignmentPostPolicyInfoRequest(courseID: "1", assignmentID: "1"),
                    value: .make(submissions: [.make(postedAt: Date())]))
        PostPolicy.postGradesButton.tap()

        SubmissionsList.postpolicy.waitToExist()
        SubmissionsList.postpolicy.tap()
        app.find(id: "PostSettings.hideMenuItem").tap()

        PostPolicy.toggleHideGradeSections.toggleOn()
        PostPolicy.hideSectionToggle(id: "1").toggleOn()

        mockGraphQL(operationName: HideAssignmentGradesPostPolicyRequest.operationName, [
            "data": [ "hideAssignmentGradesForSections": [ "assignment": [ "id": "1" ] ] ],
        ])
        PostPolicy.hideGradesButton.tap()

        SubmissionsList.postpolicy.waitToExist()
    }
}
