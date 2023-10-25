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
    func testHelp() {
        // MARK: Seed the usual stuff
        let parent = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollParent(parent, in: course)

        // MARK: Get the user logged in, navigate to Help
        logInDSUser(parent)
        let profileButton = DashboardHelper.profileButton.waitUntil(.visible)
        XCTAssertTrue(profileButton.isVisible)

        profileButton.hit()
        let helpButton = ProfileHelper.helpButton.waitUntil(.visible)
        XCTAssertTrue(helpButton.isVisible)

        helpButton.hit()

        // MARK: Check "Search the Canvas Guides" button
        let searchTheCanvasGuidesButton = HelpHelper.searchTheCanvasGuides.waitUntil(.visible)
        XCTAssertTrue(searchTheCanvasGuidesButton.isVisible)
        searchTheCanvasGuidesButton.hit()
        HelpHelper.openInSafariButton.hit()
        var browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-LMS/ct-p/canvaslms"))
        HelpHelper.returnToHelpPage(teacher: true)

        // MARK: Check "Report a Problem" button
        let reportAProblemButton = HelpHelper.reportAProblem.waitUntil(.visible)
        XCTAssertTrue(reportAProblemButton.isVisible)
        reportAProblemButton.hit()
        XCTAssertTrue(app.find(label: "Report a Problem").waitUntil(.visible).isVisible)
        app.find(label: "Cancel").hit()
        HelpHelper.navigateToHelpPage()

        // MARK: Check "Submit a Feature Idea" button
        let submitAFeatureButton = HelpHelper.submitAFeatureIdea.waitUntil(.visible)
        XCTAssertTrue(submitAFeatureButton.isVisible)
        submitAFeatureButton.hit()
        HelpHelper.openInSafariButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-Ideas-and-Themes/ct-p/canvas-ideas-themes"))
        HelpHelper.returnToHelpPage(teacher: true)

        // MARK: Check "COVID-19 Canvas Resources" button
        let covid19Button = HelpHelper.covid19.waitUntil(.visible)
        XCTAssertTrue(covid19Button.isVisible)
        covid19Button.hit()
        HelpHelper.openInSafariButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Contingency-Resources/gh-p/contingency"))
    }
}
