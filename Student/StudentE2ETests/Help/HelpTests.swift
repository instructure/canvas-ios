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
import XCTest

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
        let searchTheCanvasGuidesButton = Help.searchTheCanvasGuides.waitToExist()
        XCTAssertTrue(searchTheCanvasGuidesButton.isVisible)
        XCTAssertTrue(searchTheCanvasGuidesButton.label().contains("Search the Canvas Guides"))
        searchTheCanvasGuidesButton.tap()
        var browserURL = HelpHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-LMS/ct-p/canvaslms"))
        HelpHelper.returnToHelpPage()

        // MARK: Check "Ask Your Instructor a Question" button
        let askYourInstructorButton = Help.askYourInstructor.waitToExist()
        XCTAssertTrue(askYourInstructorButton.isVisible)
        XCTAssertTrue(askYourInstructorButton.label().contains("Ask Your Instructor a Question"))
        askYourInstructorButton.tap()
        XCTAssertTrue(app.find(label: "New Message").waitToExist().isVisible)
        app.find(label: "Cancel").tap()
        HelpHelper.navigateToHelpPage()

        // MARK: Check "Report a Problem" button
        let reportAProblemButton = Help.reportAProblem.waitToExist()
        XCTAssertTrue(reportAProblemButton.isVisible)
        XCTAssertTrue(reportAProblemButton.label().contains("Report a Problem"))
        reportAProblemButton.tap()
        XCTAssertTrue(app.find(label: "Report a Problem").waitToExist().isVisible)
        app.find(label: "Cancel").tap()
        HelpHelper.navigateToHelpPage()

        // MARK: Check "Submit a Feature Idea" button
        let submitAFeatureButton = Help.submitAFeatureIdea.waitToExist()
        XCTAssertTrue(submitAFeatureButton.isVisible)
        XCTAssertTrue(submitAFeatureButton.label().contains("Submit a Feature Idea"))
        submitAFeatureButton.tap()
        browserURL = HelpHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-Ideas-and-Themes/ct-p/canvas-ideas-themes"))
        HelpHelper.returnToHelpPage()

        // MARK: Check "COVID-19 Canvas Resources" button
        let covid19Button = Help.covid19.waitToExist()
        XCTAssertTrue(covid19Button.isVisible)
        XCTAssertTrue(covid19Button.label().contains("COVID-19 Canvas Resources"))
        covid19Button.tap()
        browserURL = HelpHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Contingency-Resources/gh-p/contingency"))
    }
}
