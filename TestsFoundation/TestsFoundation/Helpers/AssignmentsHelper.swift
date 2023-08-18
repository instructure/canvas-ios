//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core

public class AssignmentsHelper: BaseHelper {
    public static func navBar(course: DSCourse) -> XCUIElement {
        return app.find(id: "Assignments, \(course.name)")
    }

    public static func assignmentButton(assignment: DSAssignment? = nil, assignmentId: String? = nil) -> XCUIElement {
        return app.find(id: "assignment-list.assignment-list-row.cell-\(assignment?.id ?? assignmentId!)")
    }

    public static func pointsOutOf(actualScore: String, maxScore: String) -> XCUIElement {
        return app.find(id: "AssignmentDetails.gradeCircle", label: "Scored \(actualScore) out of \(maxScore) points possible")
    }

    public static func submissionListCell(user: DSUser) -> XCUIElement {
        return app.find(id: "SubmissionListCell.\(user.id)")
    }

    public struct SpeedGrader {
        public static var userButton: XCUIElement { app.find(id: "SpeedGrader.userButton") }
        public static var drawerGripper: XCUIElement { app.find(id: "SpeedGrader.drawerGripper") }
        public static var doneButton: XCUIElement { app.find(id: "SpeedGrader.doneButton") }
        public static var toolPicker: XCUIElement { app.find(id: "SpeedGrader.toolPicker") }

        public struct Segment {
            public static var grades: XCUIElement { SpeedGrader.toolPicker.find(labelContaining: "Grades") }
            public static var comments: XCUIElement { SpeedGrader.toolPicker.find(labelContaining: "Comments") }
            public static var files: XCUIElement { SpeedGrader.toolPicker.find(labelContaining: "Files") }
        }
    }

    public struct Details {
        public static var name: XCUIElement { app.find(id: "AssignmentDetails.name") }
        public static var points: XCUIElement { app.find(id: "AssignmentDetails.points") }
        public static var status: XCUIElement { app.find(id: "AssignmentDetails.status") }
        public static var due: XCUIElement { app.find(id: "AssignmentDetails.due") }
        public static var submissionTypes: XCUIElement { app.find(id: "AssignmentDetails.submissionTypes") }
        public static var submissionsButton: XCUIElement { app.find(id: "AssignmentDetails.submissionsButton") }
        public static var submitAssignmentButton: XCUIElement { app.find(id: "AssignmentDetails.submitAssignmentButton") }
        public static var successfulSubmissionLabel: XCUIElement { app.find(id: "AssignmentDetails.submittedText") }
        public static var allowedExtensions: XCUIElement { app.find(id: "AssignmentDetails.allowedExtensions") }
        public static var attemptsView: XCUIElement { app.find(id: "AssignmentDetails.attemptsView") }
        public static var circleComplete: XCUIElement { app.find(id: "AssignmentDetails.circleComplete") }
        public static var fileSubmissionButton: XCUIElement { app.find(id: "AssignmentDetails.fileSubmissionButton") }
        public static var gradeCell: XCUIElement { app.find(id: "AssignmentDetails.gradeCell") }
        public static var gradeCircle: XCUIElement { app.find(id: "AssignmentDetails.gradeCircle") }
        public static var gradeCircleOutOf: XCUIElement { app.find(id: "AssignmentDetails.gradeCircleOutOf") }
        public static var gradeDisplayGrade: XCUIElement { app.find(id: "AssignmentDetails.gradeDisplayGrade") }
        public static var gradeLatePenalty: XCUIElement { app.find(id: "AssignmentDetails.gradeLatePenalty") }
        public static var lockIcon: XCUIElement { app.find(id: "AssignmentDetails.lockIcon") }
        public static var lockSection: XCUIElement { app.find(id: "AssignmentDetails.lockSection") }
        public static var replyButton: XCUIElement { app.find(id: "AssignmentDetails.replyButton") }
        public static var submittedText: XCUIElement { app.find(id: "AssignmentDetails.submittedText") }
        public static var viewAllSubmissionsButton: XCUIElement { app.find(id: "AssignmentDetails.viewAllSubmissionsButton") }
        public static var viewSubmissionButton: XCUIElement { app.find(id: "AssignmentDetails.viewSubmissionButton") }
        public static var published: XCUIElement { app.find(id: "AssignmentDetails.published") }
        public static var unpublished: XCUIElement { app.find(id: "AssignmentDetails.unpublished") }
        public static var submissionsButtonLabel: XCUIElement {
            app.find(id: "AssignmentDetails.submissionsButton").find(type: .staticText)
        }

        public static func navBar(course: DSCourse) -> XCUIElement {
            return app.find(id: "Assignment Details, \(course.name)")
        }

        public static func description(assignment: DSAssignment) -> XCUIElement {
            return app.find(label: assignment.description!, type: .staticText)
        }

        public struct Reply {
            public static var subject: XCUIElement { app.find(id: "Compose.subject") }
            public static var body: XCUIElement { app.find(id: "Compose.body") }

            public static func recipientName(id: String) -> XCUIElement { return app.find(id: "Compose.recipientName.\(id)") }
        }
    }

    public struct Submission {
        public static var navBar: XCUIElement { app.find(id: "Text Entry") }
        public static var cancelButton: XCUIElement { app.find(id: "screen.dismiss") }
        public static var submitButton: XCUIElement { app.find(id: "TextSubmission.submitButton") }
        public static var textField: XCUIElement { app.find(id: "RichContentEditor.webView").find(type: .textView) }
    }

    @discardableResult
    public static func createAssignment(
        course: DSCourse,
        name: String = "Sample Assignment",
        description: String = "Description of ",
        published: Bool = true,
        submissionTypes: [SubmissionType] = [.online_text_entry],
        pointsPossible: Float? = 1.0,
        gradingType: GradingType? = nil,
        dueDate: Date? = nil) -> DSAssignment {
        let assignmentBody = CreateDSAssignmentRequest.RequestedDSAssignment(
                name: name,
                description: description + name,
                published: published,
                submission_types: submissionTypes,
                points_possible: pointsPossible,
                grading_type: gradingType,
                due_at: dueDate)
        return seeder.createAssignment(courseId: course.id, assignementBody: assignmentBody)
    }

    @discardableResult
    public static func createAssignmentForShareExtension(course: DSCourse) -> DSAssignment {
        let assignmentName = "Share Extension Test"
        let assignmentDescription = "This assignment is for testing Share Extension."
        let submissionTypes = [SubmissionType.external_tool, SubmissionType.media_recording, SubmissionType.online_upload, SubmissionType.online_url]
        let assignment = createAssignment(
            course: course, name: assignmentName, description: assignmentDescription,
            published: true, submissionTypes: submissionTypes, pointsPossible: 10)
        return assignment
    }

    public static func sharePhotoUsingCanvasSE(course: DSCourse, assignment: DSAssignment) -> Bool {
        XCUIDevice.shared.press(.home)
        PhotosAppHelper.launch()
        PhotosAppHelper.tapFirstPicture()
        PhotosAppHelper.tapShare()
        PhotosAppHelper.tapCanvasButton()
        PhotosAppHelper.selectCourse(course: course)
        PhotosAppHelper.selectAssignment(assignment: assignment)
        PhotosAppHelper.tapSubmitButton()

        let result = PhotosAppHelper.photosApp.staticTexts["Submission Success!"].waitForExistence(timeout: 50)
        if result {
            PhotosAppHelper.tapDoneButton()
            PhotosAppHelper.closeApp()
        }

        return result
    }

    public static func navigateToAssignments(course: DSCourse, shouldPullToRefresh: Bool = false) {
        DashboardHelper.courseCard(course: course).hit()
        if shouldPullToRefresh {
            pullToRefresh()
        }
        CourseDetailsHelper.cell(type: .assignments).hit()
    }
}
