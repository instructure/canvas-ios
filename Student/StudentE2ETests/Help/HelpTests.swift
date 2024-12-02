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

import TestsFoundation

class HelpTests: E2ETestCase {
    func testHelpPage() {
        // MARK: Seed the usual stuff
        let student = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollStudent(student, in: course)

        // MARK: Get the user logged in
        logInDSUser(student)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Help page
        HelpHelper.navigateToHelpPage()

        // MARK: Check "Search the Canvas Guides" button
        let searchTheCanvasGuidesButton = HelpHelper.searchTheCanvasGuides.waitUntil(.visible)
        XCTAssertTrue(searchTheCanvasGuidesButton.isVisible)
        searchTheCanvasGuidesButton.hit()
        var browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas/ct-p/canvas"))
        HelpHelper.returnToHelpPage()

        // MARK: Check "CUSTOM LINK" button
        let customLinkButton = HelpHelper.customLink.waitUntil(.visible)
        XCTAssertTrue(customLinkButton.isVisible)
        customLinkButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://www.instructure.com"))
        HelpHelper.returnToHelpPage()

        // MARK: Check "Ask Your Instructor a Question" button
        let askYourInstructorButton = HelpHelper.askYourInstructor.waitUntil(.visible)
        XCTAssertTrue(askYourInstructorButton.isVisible)

        askYourInstructorButton.hit()
        let sendButton = InboxHelper.Composer.sendButton.waitUntil(.visible)
        let cancelButton = InboxHelper.Composer.cancelButton.waitUntil(.visible)
        XCTAssertTrue(sendButton.isVisible)
        XCTAssertTrue(cancelButton.isVisible)

        // MARK: Check "Report a Problem" button
        cancelButton.hit()
        InboxHelper.handleCancelAlert()
        HelpHelper.navigateToHelpPage()
        let reportAProblemButton = HelpHelper.reportAProblem.waitUntil(.visible)
        XCTAssertTrue(reportAProblemButton.isVisible)

        reportAProblemButton.hit()
        let dismissButton = InboxHelper.Composer.dismissButton.waitUntil(.visible)
        let reportAProblemLabel = app.find(label: "Report a Problem").waitUntil(.visible)
        XCTAssertTrue(reportAProblemLabel.isVisible)
        XCTAssertTrue(dismissButton.isVisible)

        // MARK: Check "Submit a Feature Idea" button
        dismissButton.hit()
        HelpHelper.navigateToHelpPage()
        let submitAFeatureButton = HelpHelper.submitAFeatureIdea.waitUntil(.visible)
        XCTAssertTrue(submitAFeatureButton.isVisible)

        submitAFeatureButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("canvas-ideas-themes"))
    }
}
