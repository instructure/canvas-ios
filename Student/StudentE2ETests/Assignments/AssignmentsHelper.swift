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

import Foundation
import Core
import TestsFoundation
import XCTest

public class AssignmentsHelper: BaseHelper {
    public static var getTomorrowsDateString: String { Date().addDays(1).ISO8601Format() }
    public static var getYesterdaysDateString: String { Date().addDays(-1).ISO8601Format() }

    public static func navBar(course: DSCourse) -> Element {
        app.find(id: "Assignments, \(course.name)")
    }
    public static func assignmentButton(assignment: DSAssignment) -> Element {
        app.find(id: "assignment-list.assignment-list-row.cell-\(assignment.id)")
    }

    struct Details {
        public static var name: Element { app.find(id: "AssignmentDetails.name") }
        public static var points: Element { app.find(id: "AssignmentDetails.points") }
        public static var status: Element { app.find(id: "AssignmentDetails.status") }
        public static var due: Element { app.find(id: "AssignmentDetails.due") }
        public static var submissionTypes: Element { app.find(id: "AssignmentDetails.submissionTypes") }
        public static var submissionsButton: Element { app.find(id: "AssignmentDetails.submissionsButton") }
        public static var submissionsButtonLabel: Element { app.find(id: "AssignmentDetails.submissionsButton").rawElement.find(type: .staticText) }
        public static var description: Element { app.find(id: "AssignmentDetails.description").rawElement.find(type: .staticText) }
        public static var submitAssignmentButton: Element { app.find(id: "AssignmentDetails.submitAssignmentButton") }
        public static var successfulSubmissionLabel: Element { app.find(id: "AssignmentDetails.submittedText") }

        public static func navBar(course: DSCourse) -> Element {
            app.find(id: "Assignment Details, \(course.name)")
        }
    }

    struct Submission {
        public static var navBar: Element { app.find(id: "Text Entry") }
        public static var cancelButton: Element { app.find(id: "screen.dismiss") }
        public static var submitButton: Element { app.find(id: "TextSubmission.submitButton") }
        public static var textField: Element { app.find(id: "RichContentEditor.webView").rawElement.find(type: .textView) }
    }

    @discardableResult
    public static func createAssignment(
        course: DSCourse,
        name: String = "Sample Assignment",
        description: String = "Description of ",
        published: Bool = true,
        submissionTypes: [SubmissionType] = [.online_text_entry],
        pointsPossible: Float? = nil,
        dueDate: String? = nil) -> DSAssignment {
        let assignmentBody = CreateDSAssignmentRequest.RequestedDSAssignment(
            name: name, description: description + name, published: published, submission_types: submissionTypes, points_possible: pointsPossible, due_at: dueDate)
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

        let photosHelper = PhotosHelper()

        photosHelper.launch()
        photosHelper.tapFirstPicture()
        photosHelper.tapShare()
        photosHelper.tapCanvasButton()
        photosHelper.selectCourse(course: course)
        photosHelper.selectAssignment(assignment: assignment)
        photosHelper.tapSubmitButton()

        let result = photosHelper.photosApp.staticTexts["Submission Success!"].waitForExistence(timeout: 50)
        if result {
            photosHelper.tapDoneButton()
            photosHelper.closeApp()
        }

        return result
    }

    public static func navigateToAssignments(course: DSCourse, shouldPullToRefresh: Bool = false) {
        Dashboard.courseCard(id: course.id).tap()
        if shouldPullToRefresh {
            pullToRefresh()
        }
        CourseNavigation.assignments.tap()
    }
}
