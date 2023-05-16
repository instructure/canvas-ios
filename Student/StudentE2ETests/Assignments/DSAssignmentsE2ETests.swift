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
import TestsFoundation
import Core

class DSAssignmentsE2ETests: E2ETestCase {
    func testSubmitAssignmentWithShareExtension() {
        let defaultTimeout = TimeInterval(10)

        // Create users, course
        let users = seeder.createUsers(1)
        let course = seeder.createCourse()
        let student = users[0]
        seeder.enrollStudent(student, in: course)

        // Create assignment for testing share extension
        let assignmentName = "Share Extension Test"
        let assignmentDescription = "This assignment is for testing Share Extension."
        let assignment = seeder.createAssignment(
            courseId: course.id,
            assignementBody: .init(
                name: assignmentName,
                description: assignmentDescription,
                published: true,
                submission_types: [SubmissionType.external_tool, SubmissionType.media_recording, SubmissionType.online_upload, SubmissionType.online_url],
                points_possible: 10))

        // Log in with test user
        logInDSUser(student)

        XCUIDevice.shared.press(.home)

        // Launch the Photos app
        let photosHelper = PhotosHelper()

        photosHelper.launch()
        photosHelper.tapFirstPicture()
        photosHelper.tapShare()
        photosHelper.tapCanvasButton()
        photosHelper.selectCourse(course: course)
        photosHelper.selectAssignment(assignment: assignment)
        photosHelper.tapSubmitButton()

        // Wait for the success message to exist
        XCTAssertTrue(photosHelper.photosApp.staticTexts["Submission Success!"].waitForExistence(timeout: 40))

        photosHelper.tapDoneButton()
        photosHelper.closeApp()
    }
}
