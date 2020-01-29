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

class IPadSpeedGraderTests: CoreUITestCase {
    func testSpeedGrader() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let course = mock(course: APICourse.make())
        let enrollment1 = APIEnrollment.make(id: "1", user_id: "1", user: .make(id: "1", name: "User 1", sortable_name: "User 1", short_name: "User 1"))
        let enrollment2 = APIEnrollment.make(id: "2", user_id: "2", user: .make(id: "2", name: "User 2", sortable_name: "User 2", short_name: "User 2"))
        let enrollment3 = APIEnrollment.make(id: "3", user_id: "3", user: .make(id: "3", name: "User 3", sortable_name: "User 3", short_name: "User 3"))
        let submissions = [
            APISubmission.make(id: "1", user_id: "1", user: .make(id: "1", name: "User 1", short_name: "User 1")),
            APISubmission.make(id: "2", user_id: "2", user: .make(id: "2", name: "User 2", short_name: "User 2")),
            APISubmission.make(id: "3", user_id: "3", user: .make(id: "3", name: "User 3", short_name: "User 3")),
        ]
        mockBaseRequests()
        mockEncodableRequest("https://canvas.instructure.com/api/v1/courses/1/lti_apps/launch_definitions?per_page=99&placements%5B%5D=course_navigation", value: [String]())
        mockEncodableRequest("courses/\(course.id)/grading_periods", value: APIGradingPeriodResponse(grading_periods: []))
        mockData(GetTabsRequest(context: course, perPage: nil), value: [
            APITab.make(
                id: ID("assignments"),
                html_url: URL(string: "/courses/\(course.id)/assignments")!,
                label: "Assignments"
            ),
        ])
        let assignment = APIAssignment.make(id: ID("1"))
        mockData(
            GetAssignmentsRequest(
                courseID: "1",
                orderBy: nil,
                include: [.all_dates, .discussion_topic, .observed_users, .overrides]),
            value: [assignment]
        )
        mockData(
            GetAssignmentRequest(
                courseID: course.id.value,
                assignmentID: assignment.id.value,
                allDates: true,
                include: [.overrides]
            ),
            value: assignment
        )
        mockData(
            GetAssignmentGroupsRequest(
                courseID: course.id.value,
                gradingPeriodID: "undefined",
                include: [.assignments],
                perPage: 99
            ),
            value: [.make(assignments: [assignment])]
        )
        mockData(
            GetSubmissionsRequest(
                context: ContextModel(.course, id: course.id.value),
                assignmentID: assignment.id.value,
                grouped: true,
                include: [
                    .rubric_assessment,
                    .submission_comments,
                    .submission_history,
                    .total_scores,
                    .user,
                ]
            ),
            value: submissions
        )
        mockData(
            GetSubmissionsRequest(
                context: ContextModel(.course, id: course.id.value),
                assignmentID: assignment.id.value,
                grouped: true,
                include: [
                    .rubric_assessment,
                    .submission_comments,
                    .submission_history,
                    .total_scores,
                    .user,
                    .group,
                ]
            ),
            value: submissions
        )
        mockData(
            GetSubmissionsRequest(
                context: ContextModel(.course, id: course.id.value),
                assignmentID: assignment.id.value,
                grouped: false,
                include: [
                    .rubric_assessment,
                    .submission_comments,
                    .submission_history,
                    .total_scores,
                    .user,
                    .group,
                ]
            ),
            value: submissions
        )
        mockEncodableRequest(
            "courses/\(course.id)/assignments/\(assignment.id)/submission_summary",
            value: APISubmission.make()
        )
        let avatarURL = URL(string: "https://canvas.instructure.com/avatar")!
        mockURL(avatarURL)
        mockData(
            GetEnrollmentsRequest(context: ContextModel(.course, id: "1"), userID: nil, gradingPeriodID: nil, includes: [.avatar_url]),
            value: [enrollment1, enrollment2, enrollment3]
        )
        mockData(GetGroupsRequest(context: ContextModel(.course, id: "1")), value: [])
        mockData(GetConversationsRequest(include: [.participant_avatars], perPage: 50, scope: nil), value: [])
        mockGraphQL(operationName: "SubmissionList", SubmissionListFixture.submissionList)
        logIn()
        SpringBoard.shared.setupSplitScreenWithSafariOnRight()
        SpringBoard.shared.moveSplit(toFraction: 0.5)
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "1").tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        app.find(labelContaining: "User 1").waitToExist()
        app.find(labelContaining: "User 2").waitToExist()
        app.find(labelContaining: "User 3").waitToExist()
        SubmissionsList.row(contextID: "2").tap()
        SpeedGrader.dismissTutorial()
        SpeedGrader.doneButton.waitToExist()
        SpeedGrader.userName(userID: "2").waitToExist()
        XCTAssertTrue(SpeedGrader.userName(userID: "2").isVisible)
        XCTAssertFalse(SpeedGrader.userName(userID: "1").isVisible)
        XCTAssertFalse(SpeedGrader.userName(userID: "3").isVisible)
    }

}
