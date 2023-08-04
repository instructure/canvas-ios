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

        logInDSUser(student)

        // MARK: Navigate to Help page
        HelpHelper.navigateToHelpPage()

        // MARK: Check "Search the Canvas Guides" button
        let searchTheCanvasGuidesButton = HelpHelper.searchTheCanvasGuides.waitUntil(.visible)
        XCTAssertTrue(searchTheCanvasGuidesButton.isVisible)
        XCTAssertTrue(searchTheCanvasGuidesButton.label.contains("Search the Canvas Guides"))
        searchTheCanvasGuidesButton.hit()
        var browserURL = HelpHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-LMS/ct-p/canvaslms"))
        HelpHelper.returnToHelpPage()

        // MARK: Check "Ask Your Instructor a Question" button
        let askYourInstructorButton = HelpHelper.askYourInstructor.waitUntil(.visible)
        XCTAssertTrue(askYourInstructorButton.isVisible)
        XCTAssertTrue(askYourInstructorButton.label.contains("Ask Your Instructor a Question"))
        askYourInstructorButton.hit()
        XCTAssertTrue(app.find(label: "New Message").waitUntil(.visible).isVisible)
        app.find(label: "Cancel").hit()
        HelpHelper.navigateToHelpPage()

        // MARK: Check "Report a Problem" button
        let reportAProblemButton = HelpHelper.reportAProblem.waitUntil(.visible)
        XCTAssertTrue(reportAProblemButton.isVisible)
        XCTAssertTrue(reportAProblemButton.label.contains("Report a Problem"))
        reportAProblemButton.hit()
        XCTAssertTrue(app.find(label: "Report a Problem").waitUntil(.visible).isVisible)
        app.find(label: "Cancel").hit()
        HelpHelper.navigateToHelpPage()

        // MARK: Check "Submit a Feature Idea" button
        let submitAFeatureButton = HelpHelper.submitAFeatureIdea.waitUntil(.visible)
        XCTAssertTrue(submitAFeatureButton.isVisible)
        XCTAssertTrue(submitAFeatureButton.label.contains("Submit a Feature Idea"))
        submitAFeatureButton.hit()
        browserURL = HelpHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-Ideas-and-Themes/ct-p/canvas-ideas-themes"))
        HelpHelper.returnToHelpPage()

        // MARK: Check "COVID-19 Canvas Resources" button
        let covid19Button = HelpHelper.covid19.waitUntil(.visible)
        XCTAssertTrue(covid19Button.isVisible)
        XCTAssertTrue(covid19Button.label.contains("COVID-19 Canvas Resources"))
        covid19Button.hit()
        browserURL = HelpHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Contingency-Resources/gh-p/contingency"))
    }
}
