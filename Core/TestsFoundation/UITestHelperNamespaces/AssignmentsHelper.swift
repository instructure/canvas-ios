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
import Foundation
import XCTest

public class AssignmentsHelper: BaseHelper {
    public static func navBar(course: DSCourse) -> XCUIElement {
        return app.find(label: "Assignments, \(course.name)", type: .staticText)
    }

    public static func assignmentButton(assignment: DSAssignment) -> XCUIElement {
        return app.find(id: "AssignmentList.\(assignment.id)")
    }

    public static func pointsOutOf(actualScore: String, maxScore: String) -> XCUIElement {
        return app.find(id: "AssignmentDetails.gradeCircle", label: "Scored \(actualScore) out of \(maxScore) points possible")
    }

    public static func submissionListCell(user: DSUser) -> XCUIElement {
        return app.find(id: "SubmissionListCell.\(user.id)")
    }

    public static func oneNeedsGradingLabel(assignmentItem: XCUIElement) -> XCUIElement {
        return assignmentItem.find(label: "1 Needs Grading", type: .staticText)
    }

    public struct SpeedGrader {
        public static var drawerGripper: XCUIElement { app.find(id: "SpeedGrader.drawerGripper") }
        public static var toolPicker: XCUIElement { app.find(id: "SpeedGrader.toolPicker") }
        public static var gradeButton: XCUIElement { app.find(id: "SpeedGrader.gradeButton") }
        public static var gradeSlider: XCUIElement { app.find(label: "Grade Slider", type: .slider) }

        // MARK: Navigation bar
        // Speedgrader is fullscreen so there's only one navigation bar
        public static var navigationBar: XCUIElement { app.find(type: .navigationBar) }
        public static var doneButton: XCUIElement { navigationBar.find(id: "SpeedGrader.doneButton") }
        public static var postPolicyButton: XCUIElement { navigationBar.find(id: "SpeedGrader.postPolicyButton") }
        public static func assignmentNameLabel(assignment: DSAssignment) -> XCUIElement {
            navigationBar.find(label: assignment.name, type: .staticText)
        }
        public static func courseNameLabel(course: DSCourse) -> XCUIElement {
            navigationBar.find(label: course.name, type: .staticText)
        }

        // MARK: User
        public static var userButton: XCUIElement { app.find(id: "SpeedGrader.userButton") }
        public static func userNameLabel(user: DSUser) -> XCUIElement {
            return userButton.find(label: user.name, type: .staticText)
        }

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
        public static var submissionButton: XCUIElement { app.find(id: "AssignmentDetails.viewSubmissionButton") }
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
        public static var oneNeedsGradingButton: XCUIElement { app.find(label: "Needs Grading", type: .button) }
        public static var notSubmittedButton: XCUIElement { viewAllSubmissionsButton.find(labelContaining: "Not Submitted", type: .button) }
        public static var viewSubmissionButton: XCUIElement { app.find(id: "AssignmentDetails.viewSubmissionButton") }
        public static var published: XCUIElement { app.find(id: "AssignmentDetails.published") }
        public static var unpublished: XCUIElement { app.find(id: "AssignmentDetails.unpublished") }
        public static var oneGradedButton: XCUIElement { app.find(label: "Graded", type: .button) }
        public static var editButton: XCUIElement { app.find(label: "Edit", type: .button) }
        public static var isLockedLabel: XCUIElement { app.find(label: "This assignment is locked", type: .staticText) }
        public static var pandaLockedImage: XCUIElement { app.find(id: "PandaLocked", type: .image) }
        public static var submissionAndRubricButton: XCUIElement { app.find(label: "Submission & Rubric", type: .button) }

        // Reminder
        public static var reminder: XCUIElement { app.find(id: "AssignmentDetails.reminder") }
        public static var addReminder: XCUIElement { app.find(id: "AssignmentDetails.addReminder") }
        public static var removeReminder: XCUIElement { app.find(label: "xLine", type: .button) }
        public static var removalLabel: XCUIElement { app.find(label: "Delete Reminder", type: .staticText)}
        public static var removalAreYouSureLabel: XCUIElement { app.find(labelContaining: "Are you sure", type: .staticText)}
        public static var noButton: XCUIElement { app.find(label: "No", type: .button) }
        public static var yesButton: XCUIElement { app.find(label: "Yes", type: .button) }

        // Other
        public static var backButton: XCUIElement {
            return app.find(type: .navigationBar).find(label: "Back", type: .button)
        }

        public static func navBar(course: DSCourse) -> XCUIElement {
            return app.find(id: "Assignment details, \(course.name)")
        }

        public static func description(assignment: DSAssignment) -> XCUIElement {
            return app.find(label: assignment.description!, type: .staticText)
        }

        public struct Reply {
            public static var subject: XCUIElement { app.find(id: "Compose.subject") }
            public static var body: XCUIElement { app.find(id: "Compose.body") }

            public static func recipientName(id: String) -> XCUIElement { return app.find(id: "Compose.recipientName.\(id)") }
        }

        public struct SubmissionDetails {
            public static var attemptPicker: XCUIElement { app.find(id: "SubmissionDetails.attemptPicker") }
            public static var attemptPickerItems: [XCUIElement] {
                app.findAll(idStartingWith: "SubmissionDetails.attemptPickerItem.")
            }
            public static var drawerGripper: XCUIElement { app.find(id: "SubmissionDetails.drawerGripper") }
        }

        public struct SubmissionComments {
            public static var commentsButton: XCUIElement {
                app.find(type: .segmentedControl).find(labelContaining: "Comments", type: .button)
            }
            public static var filesButton: XCUIElement {
                app.find(type: .segmentedControl).find(labelContaining: "Files", type: .button)
            }
            public static var rubricButton: XCUIElement {
                app.find(type: .segmentedControl).find(labelContaining: "Rubric", type: .button)
            }

            public static var addMediaButton: XCUIElement { app.find(id: "SubmissionComments.addMediaButton") }
            public static var commentTextView: XCUIElement { app.find(id: "SubmissionComments.commentTextView") }
            public static var addCommentButton: XCUIElement { app.find(id: "SubmissionComments.addCommentButton") }
            public static var chatBubble: XCUIElement { app.find(id: "chatBubble") }

            public static func attemptView(index: Int) -> XCUIElement {
                return app.find(id: "SubmissionComments.attemptView.\(index)")
            }

            public static func rubricTitle(rubric: DSRubric) -> XCUIElement {
                return app.find(id: "RubricCell.title.\(rubric.data[0].id)")
            }

            public static func rubricDescriptionButton(rubric: DSRubric) -> XCUIElement {
                return app.find(id: "RubricCell.descButton.\(rubric.data[0].id)")
            }

            public static func rubricRatingButton(rubric: DSRubric, index: Int) -> XCUIElement {
                return app.find(id: "RubricCell.RatingButton.\(rubric.data[0].id)-\(index).0")
            }

            public static func rubricRatingTitle(rubric: DSRubric) -> XCUIElement {
                return app.find(id: "RubricCell.ratingTitle.\(rubric.data[0].id)")
            }

            public static func rubricLongDescriptionLabel(rubric: DSRubric) -> XCUIElement {
                return app.find(label: rubric.data[0].long_description!, type: .staticText)
            }
        }

        public struct Reminder {
            public static var fiveMinButton: XCUIElement { app.find(label: "5 Minutes Before", type: .button) }
            public static var fifteenMinButton: XCUIElement { app.find(label: "15 Minutes Before", type: .button) }
            public static var thirtyMinButton: XCUIElement { app.find(label: "30 Minutes Before", type: .button) }
            public static var oneHourButton: XCUIElement { app.find(label: "1 Hour Before", type: .button) }
            public static var oneDayButton: XCUIElement { app.find(label: "1 Day Before", type: .button) }
            public static var oneWeekButton: XCUIElement { app.find(label: "1 Week Before", type: .button) }
            public static var customButton: XCUIElement { app.find(label: "Custom", type: .button) }
            public static var doneButton: XCUIElement { app.find(label: "Done", type: .button) }

            // Alert message
            public static var okButton: XCUIElement { app.find(label: "OK", type: .button) }

            public static var reminderCreationFailed: XCUIElement {
                app.find(label: "Reminder Creation Failed", type: .staticText)
            }

            public static var chooseFutureTime: XCUIElement {
                app.find(label: "Please choose a future time for your reminder!", type: .staticText)
            }

            public static var youHaveAlreadySet: XCUIElement {
                app.find(label: "You have already set a reminder for this time.", type: .staticText)
            }

            // Custom date
            public static var numberPickerWheel: XCUIElement {
                app.find(id: "AssignmentReminder.numberPicker", type: .picker).waitUntil(.visible).find(type: .pickerWheel)
            }

            public static var timeUnitPickerWheel: XCUIElement {
                app.find(id: "AssignmentReminder.timeUnitPicker", type: .picker).waitUntil(.visible).find(type: .pickerWheel)
            }

            // Notification Banner
            public static var notificationBanner: XCUIElement {
                XCUIApplication(bundleIdentifier: "com.apple.springboard")
                  .otherElements["Notification"]
                  .descendants(matching: .any)
                  .matching(NSPredicate(format: "label CONTAINS[c] ', now,'"))
                  .firstMatch
            }
        }

        // Teacher
        public struct Submissions {
            public static var needsGradingLabel: XCUIElement { app.find(labelContaining: "Needs Grading") }
            public static var backButton: XCUIElement { app.find(label: "Back", type: .button) }

            public static func cell(student: DSUser) -> XCUIElement {
                return app.find(id: "SubmissionListCell.\(student.id)")
            }

            public static var navBar: XCUIElement {
                return app.find(idStartingWith: "Submissions", type: .navigationBar)
            }
        }

        public struct Editor {
            public static var titleField: XCUIElement { app.find(id: "AssignmentEditor.titleField") }
            public static var webView: XCUIElement { app.find(id: "RichContentEditor.webView") }
            public static var pointsField: XCUIElement { app.find(id: "AssignmentEditor.pointsField") }
            public static var gradingTypeButton: XCUIElement { app.find(id: "AssignmentEditor.gradingTypeButton") }
            public static var doneButton: XCUIElement { app.find(id: "AssignmentEditor.doneButton") }
        }
    }

    public struct Submission {
        public static var navBar: XCUIElement { app.find(id: "Text Entry") }
        public static var cancelButton: XCUIElement { app.find(id: "screen.dismiss") }
        public static var submitButton: XCUIElement { app.find(id: "TextSubmission.submitButton") }
        public static var textField: XCUIElement { app.find(id: "RichContentEditor.webView").find(type: .textField) }
        public static var textView: XCUIElement { app.find(label: "Submission text", type: .textView) }

        public static var pandaFilePicker: XCUIElement { app.find(id: "PandaFilePicker") }
        public static var filesButton: XCUIElement { app.find(id: "FilePicker.filesButton") }
        public static var studioLabel: XCUIElement { app.find(labelContaining: "Studio") }
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
        dueDate: Date? = nil,
        lockAt: Date? = nil,
        unlockAt: Date? = nil,
        assignmentGroup: DSAssignmentGroup? = nil,
        sleepAfter: Bool = true,
        allowedExtensions: [String]? = nil
    ) -> DSAssignment {
        let assignmentBody = CreateDSAssignmentRequest.RequestedDSAssignment(
            name: name,
            description: description + name,
            published: published,
            submission_types: submissionTypes,
            points_possible: pointsPossible,
            grading_type: gradingType,
            due_at: dueDate,
            lock_at: lockAt,
            unlock_at: unlockAt,
            assignment_group_id: assignmentGroup?.id ?? nil,
            allowed_extensions: allowedExtensions
        )
        let result = seeder.createAssignment(courseId: course.id, assignementBody: assignmentBody)
        if sleepAfter { sleep(1) }
        return result
    }

    @discardableResult
    public static func createAssignmentForShareExtension(course: DSCourse) -> DSAssignment {
        let assignmentName = "Share Extension Test"
        let assignmentDescription = "This assignment is for testing Share Extension."
        let submissionTypes = [SubmissionType.external_tool, SubmissionType.media_recording, SubmissionType.online_upload, SubmissionType.online_url]
        let assignment = createAssignment(
            course: course, name: assignmentName, description: assignmentDescription,
            published: true, submissionTypes: submissionTypes, pointsPossible: 10, sleepAfter: true)
        return assignment
    }

    public static func sharePhotoUsingCanvasSE(
        course: DSCourse,
        assignment: DSAssignment
    ) -> Bool {
        XCUIDevice.shared.press(.home)
        PhotosAppHelper.launch()
        PhotosAppHelper.tapFirstPicture()
        PhotosAppHelper.tapShare()
        PhotosAppHelper.tapCanvasButton()
        PhotosAppHelper.selectCourse(course: course)
        PhotosAppHelper.selectAssignment(assignment: assignment)
        PhotosAppHelper.tapSubmitButton()

        let successMessage = PhotosAppHelper.photosApp.descendants(matching: .staticText).matching(label: "Submission Success!").firstMatch
        let result = successMessage.waitForExistence(timeout: 50)
        if result {
            PhotosAppHelper.tapDoneButton()
            PhotosAppHelper.closeApp()
        }

        return result
    }

    public static func navigateToAssignments(
        course: DSCourse,
        shouldPullToRefresh: Bool = false
    ) {
        DashboardHelper.courseCard(course: course).hit()
        if shouldPullToRefresh {
            app.pullToRefresh()
        }
        CourseDetailsHelper.cell(type: .assignments).hit()
    }

    @discardableResult
    public static func createAssignments(
        in course: DSCourse,
        count: Int,
        dueDate: Date? = nil
    ) -> [DSAssignment] {
        var assignments = [DSAssignment]()
        for i in 1...count {
            let name = "Sample Assignment \(i)"
            let assignmentBody = CreateDSAssignmentRequest.RequestedDSAssignment(
                name: name,
                description: "Description of \(name)",
                published: true,
                submission_types: [.online_text_entry],
                points_possible: 1.0,
                grading_type: .letter_grade,
                due_at: dueDate)
            assignments.append(seeder.createAssignment(courseId: course.id, assignementBody: assignmentBody))
        }
        return assignments
    }

    public static func createRubric(
        in course: DSCourse,
        rubricAssociationId: String,
        rubricAssociationType: DSRubricAssociationType,
        pointsPossible: Float = 1.0
    ) -> DSRubric {
        let rubricCriteriaRating1 = CreateDSRubricRequest.RubricCriteriaRating(points: 0, description: "Rating 0")
        let rubricCriteriaRating2 = CreateDSRubricRequest.RubricCriteriaRating(points: 1, description: "Rating 1")
        let longDescription = "Not so long description of test criteria of test rubric"
        let rubricCriteria = CreateDSRubricRequest.RubricCriteria(
            description: "Criteria Description",
            long_description: longDescription,
            points: pointsPossible,
            ratings: ["0": rubricCriteriaRating1, "1": rubricCriteriaRating2])
        let description = "Test description of test rubric"
        let rubricRequestBody = CreateDSRubricRequest.RequestedDSRubric(criteria: ["0": rubricCriteria], description: description)
        let rubricAssociationRequestBody = CreateDSRubricRequest.RequestedDSRubricAssociation(
            associationId: rubricAssociationId,
            associationType: rubricAssociationType,
            purpose: "grading")
        return seeder.createRubric(
            course: course,
            title: "Test Rubric",
            pointsPossible: pointsPossible,
            rubricAssociationId: rubricAssociationId,
            rubricBody: rubricRequestBody,
            rubricAssociationBody: rubricAssociationRequestBody)
    }

    public static func createAssignmentGroup(
        in course: DSCourse,
        name: String = "Sample Assignment Group"
    ) -> DSAssignmentGroup {
        let body = CreateDSAssignmentGroupRequest.Body(name: name)
        return seeder.createAssignmentGroup(course: course, assignmentGroupBody: body)
    }
}
