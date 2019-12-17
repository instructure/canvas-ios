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

class SpeedGraderTests: TeacherUITestCase {
    override var user: UITestUser? { nil }

    func testSubmissionCommentAttachments() {
        mockBaseRequests()
        mockData(GetAssignmentRequest(courseID: "1", assignmentID: "1", allDates: true, include: [.overrides]), value: .make(id: "1"))
        mockData(GetGroupsRequest(context: ContextModel(.course, id: "1")), value: [])
        let image = UIImage.icon(.paperclip)
        let attachment = APIFile.make(
            id: "1",
            display_name: "screenshot.png",
            url: URL(string: "data:image/png;base64,\(image.pngData()!.base64EncodedString())")!
        )
        mockURL(attachment.url, data: UIImage.icon(.paperclip).pngData())
        mockData(
            GetSubmissionsRequest(
                context: ContextModel(.course, id: "1"),
                assignmentID: "1",
                grouped: true,
                include: [.group, .rubric_assessment, .submission_comments, .submission_history, .total_scores, .user]
            ),
            value: [.make(user_id: "1", submission_comments: [.make(attachments: [attachment])])]
        )
        mockData(
            GetSubmissionsRequest(
                context: ContextModel(.course, id: "1"),
                assignmentID: "1",
                grouped: false,
                include: [.group, .rubric_assessment, .submission_comments, .submission_history, .total_scores, .user]
            ),
            value: [.make(user_id: "1", submission_comments: [.make(attachments: [attachment])])]
        )
        mockEncodableRequest("courses/1/enrollments?include[]=avatar_url", value: [
            APIEnrollment.make(user_id: "1", user: .make(id: "1")),
        ])
        mockEncodableRequest("courses/1/assignments/1/submission_summary", value: APISubmission.make())
        show("/courses/1/assignments/1/submissions/1")
        dismissTutorial()
        app.find(id: "speedgrader.segment-control").waitToExist()
        app.segmentedControls.buttons["Comments"].tap()
        app.find(id: "CommentAttachment-1").tap()
        app.find(id: "AttachmentView.image").waitToExist()
        app.find(id: "attachment-view.share-btn").waitToExist()
        app.find(label: "Attachment").waitToExist()
        NavBar.dismissButton.tap()
        app.find(id: "AttachmentView.image").waitToVanish()
    }

    func dismissTutorial() {
        let button = app.find(id: "tutorial.button-swipe-tutorial")
        let exists = button.rawElement.waitForExistence(timeout: 3)
        if exists {
            button.tap()
            button.waitToVanish()
        }
    }
}

class SpeedGraderIPadTests: CoreUITestCase {
    override var user: UITestUser? { nil }

    func testSpeedGrader() {
        XCUIDevice.shared.orientation = .landscapeLeft
        SpringBoard.shared.setupSplitScreenWithSafariOnRight()
        SpringBoard.shared.moveSplit(toFraction: 0.75)
        let course = mock(course: APICourse.make())
        let enrollment1 = APIEnrollment.make(id: "1", user_id: "1", user: .make(id: "1", name: "User 1", sortable_name: "User 1", short_name: "User 1"))
        let enrollment2 = APIEnrollment.make(id: "2", user_id: "2", user: .make(id: "2", name: "User 2", sortable_name: "User 2", short_name: "User 2"))
        let enrollment3 = APIEnrollment.make(id: "3", user_id: "3", user: .make(id: "3", name: "User 3", sortable_name: "User 3", short_name: "User 3"))
        let submissions = [
            APISubmission.make(id: "1", user_id: "1", user: .make(id: "1", name: "User 1", short_name: "User 1")),
            APISubmission.make(id: "2", user_id: "2", user: .make(id: "2", name: "User 2", short_name: "User 1")),
            APISubmission.make(id: "3", user_id: "3", user: .make(id: "3", name: "User 3", short_name: "User 1")),
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
        mockGraphQL(["data": [
            "assignment": [
                "id": "1",
                "name": "Assignment 1",
                "pointsPossible": 10,
                "gradeGroupStudentsIndividually": false,
                "anonymousGrading": false,
                "muted": true,
                "gradingType": "points",
                "groupSet": nil,
                "course": [
                    "name": "Course 1",
                    "sections": [
                        "edges": [
                            [
                                "section": ["id": "1", "name": "Section 1", "__typename": "Section"],
                                "__typename": "SectionEdge",
                            ]
                        ],
                        "__typename": "SectionConnection",
                    ],
                    "__typename": "Course",
                ],
                "submissions": [
                    "edges": [
                        ["submission": [
                            "grade": nil,
                            "score": nil,
                            "late": false,
                            "missing": false,
                            "excused": false,
                            "submittedAt": "2019-08-10T16:37:58-06:00",
                            "gradingStatus": "needs_grading",
                            "gradeMatchesCurrentSubmission": true,
                            "state": "submitted",
                            "postedAt": nil,
                            "user": ["id": "1", "avatarUrl": nil, "name": "User 1", "__typename": "User"],
                            "__typename": "Submission",
                        ], "__typename": "SubmissionEdge"],
                        ["submission": [
                            "grade": nil,
                            "score": nil,
                            "late": false,
                            "missing": false,
                            "excused": false,
                            "submittedAt": "2019-08-10T16:37:58-06:00",
                            "gradingStatus": "needs_grading",
                            "gradeMatchesCurrentSubmission": true,
                            "state": "submitted",
                            "postedAt": nil,
                            "user": ["id": "2", "avatarUrl": nil, "name": "User 2", "__typename": "User"],
                            "__typename": "Submission",
                        ], "__typename": "SubmissionEdge"],
                        ["submission": [
                            "grade": nil,
                            "score": nil,
                            "late": false,
                            "missing": false,
                            "excused": false,
                            "submittedAt": "2019-08-10T16:37:58-06:00",
                            "gradingStatus": "needs_grading",
                            "gradeMatchesCurrentSubmission": true,
                            "state": "submitted",
                            "postedAt": nil,
                            "user": ["id": "3", "avatarUrl": nil, "name": "User 3", "__typename": "User"],
                            "__typename": "Submission",
                        ], "__typename": "SubmissionEdge"],
                    ],
                    "__typename": "SubmissionConnection",
                ],
                "groupedSubmissions": nil,
                "__typename": "Assignment",
            ],
        ]])
        mockData(
            GetEnrollmentsRequest(context: ContextModel(.course, id: "1"), userID: nil, gradingPeriodID: nil, includes: [.avatar_url]),
            value: [enrollment1, enrollment2, enrollment3]
        )
        mockData(GetGroupsRequest(context: ContextModel(.course, id: "1")), value: [])
        logIn()
        Dashboard.courseCard(id: course.id).tap()
        CourseNavigation.assignments.tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        app.find(labelContaining: "User 1").waitToExist()
        app.find(labelContaining: "User 2").waitToExist()
        app.find(labelContaining: "User 3").waitToExist()
        SubmissionsList.row(contextID: "2").tap()
        app.find(labelContaining: "User 1").waitToVanish()
        app.find(labelContaining: "User 2").waitToExist()
    }
}

public class SpringBoard {
    private init() {}
    public static let shared = SpringBoard()

    let sbApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")

    func relativeCoordinate(x: CGFloat, y: CGFloat) -> XCUICoordinate {
        let offset: CGVector
        switch XCUIDevice.shared.orientation {
        case .portrait:
            offset = CGVector(dx: x, dy: y)
        case .portraitUpsideDown:
            offset = CGVector(dx: 1 - x, dy: 1 - y)
        case .landscapeLeft:
            offset = CGVector(dx: 1 - y, dy: x)
        case .landscapeRight:
            offset = CGVector(dx: y, dy: 1 - x)
        default:
            fatalError("Unknown orientation")
        }
        return sbApp.coordinate(withNormalizedOffset: offset)
    }

    func moveSplit(toFraction fraction: CGFloat) {
        let divider = sbApp.find(id: "SideAppDivider")
        let dest = relativeCoordinate(x: fraction, y: 0.5)
        divider.center.press(forDuration: 0, thenDragTo: dest)
        sleep(1)
    }

    func resetMultitasking() {
        if sbApp.find(id: "SideAppDivider").exists {
            moveSplit(toFraction: 1)
        }
        app.activate()
    }

    func bringUpDock() {
        let start = relativeCoordinate(x: 0.5, y: 1.0)
        let dest = relativeCoordinate(x: 0.5, y: 0.9)
        start.press(forDuration: 0, thenDragTo: dest)
    }

    func setupSplitScreenWithSafariOnRight() {
        resetMultitasking()

        bringUpDock()

        let dock = sbApp.find(id: "user icon list view")
        let safari = dock.rawElement.find(id: "Safari")
        let dest = relativeCoordinate(x: 1.0, y: 0.5)
        safari.center.press(forDuration: 1, thenDragTo: dest)
    }
}
