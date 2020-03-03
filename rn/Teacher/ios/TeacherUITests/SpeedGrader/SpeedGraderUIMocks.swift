//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
import TestsFoundation
import CoreUITests
@testable import Core

// common mocking needs between iPad and iPhone UI tests
struct SpeedGraderUIMocks {
    var users: [APIUser]
    var enrollments: [APIEnrollment]
    var submissions: [APISubmission]
    var assignment: APIAssignment = APIAssignment.make(id: 1)

    init() {
        users = (1...3).map { id in
            let name = "User \(id)"
            return APIUser.make(id: ID("\(id)"), name: name, sortable_name: name, short_name: name)
        }
        enrollments = users.map { user in
            APIEnrollment.make(id: user.id, user_id: user.id, user: user)
        }
        submissions = users.map { user in
            APISubmission.make(id: user.id, user_id: user.id, user: APISubmissionUser.make(from: user))
        }
    }

    func mock(for testCase: CoreUITestCase) {
        testCase.mockBaseRequests()
        let course = testCase.baseCourse
        testCase.mockEncodableRequest("courses/\(course.id)/grading_periods", value: APIGradingPeriodResponse(grading_periods: []))

        let tabsNeeded: [CourseNavigation] = [ .assignments, .quizzes ]
        let tabs = tabsNeeded.map { tab in
            APITab.make(
                id: ID(tab.rawValue),
                html_url: URL(string: "/courses/\(course.id)/\(tab.rawValue)")!,
                label: "\(tab.rawValue.capitalized)"
            )
        }
        testCase.mockData(GetTabsRequest(context: course, perPage: nil), value: tabs)
        testCase.mockData(
            GetAssignmentsRequest(
                courseID: course.id,
                orderBy: nil,
                include: [.all_dates, .discussion_topic, .observed_users, .overrides]),
            value: [assignment]
        )
        testCase.mock(assignment: assignment)
        testCase.mockData(
            GetSubmissionSummaryRequest(context: course, assignmentID: assignment.id.value),
            value: .make(graded: 11, ungraded: 22, not_submitted: 88)
        )

        testCase.mockData(
            GetAssignmentGroupsRequest(
                courseID: course.id.value,
                include: [.assignments],
                perPage: 99
            ),
            value: [.make(assignments: [assignment])]
        )
        testCase.mockData(
            GetAssignmentGroupsRequest(courseID: course.id, perPage: 99),
            value: [.make()]
        )

        for grouped in [false, true] {
            for include in [[], [GetSubmissionsRequest.Include.group]] {
                testCase.mockData(
                    GetSubmissionsRequest(
                        context: ContextModel(.course, id: course.id.value),
                        assignmentID: assignment.id.value,
                        grouped: grouped,
                        include: include + [
                            .rubric_assessment,
                            .submission_comments,
                            .submission_history,
                            .total_scores,
                            .user,
                        ]
                    ),
                    value: submissions
                )
            }
        }

        testCase.mockData(
            GetEnrollmentsRequest(context: ContextModel(.course, id: "1"), userID: nil, gradingPeriodID: nil, includes: [.avatar_url]),
            value: enrollments
        )
        testCase.mockData(GetGroupsRequest(context: ContextModel(.course, id: "1")), value: [])
        testCase.mockGraphQL(operationName: "SubmissionList", SubmissionListFixture.submissionList)
    }
}
