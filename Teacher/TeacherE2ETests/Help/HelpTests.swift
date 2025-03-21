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
import XCTest

class HelpTests: E2ETestCase {
    func testHelpPage() {
        // MARK: Seed the usual stuff
        let teacher = seeder.createUser()
        let course = seeder.createCourse()
        seeder.enrollTeacher(teacher, in: course)

        // MARK: Get the user logged in
        logInDSUser(teacher)
        let courseCard = DashboardHelper.courseCard(course: course).waitUntil(.visible)
        XCTAssertTrue(courseCard.isVisible)

        // MARK: Navigate to Help page, Check "Search the Canvas Guides" button
        HelpHelper.navigateToHelpPage()
        let searchTheCanvasGuidesButton = HelpHelper.searchTheCanvasGuides.waitUntil(.visible)
        XCTAssertTrue(searchTheCanvasGuidesButton.isVisible)

        searchTheCanvasGuidesButton.hit()
        HelpHelper.openInSafariButton.hit()
        var browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas/ct-p/canvas"))

        // MARK: Check "Conference Guides for Remote Classrooms" button
        HelpHelper.returnToHelpPage(teacher: true)
        let conferenceGuidesButton = HelpHelper.conferenceGuides.waitUntil(.visible)
        XCTAssertTrue(conferenceGuidesButton.isVisible)

        conferenceGuidesButton.hit()
        HelpHelper.openInSafariButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-LMS-Blog/Web-Conferencing-Resources"))

        // MARK: Check "Report a Problem" button
        HelpHelper.returnToHelpPage(teacher: true)
        let reportAProblemButton = HelpHelper.reportAProblem.waitUntil(.visible)
        XCTAssertTrue(reportAProblemButton.isVisible)

        reportAProblemButton.hit()
        XCTAssertTrue(app.find(label: "Report a Problem").waitUntil(.visible).isVisible)

        // MARK: Check "Ask the Community" button
        app.find(label: "Cancel").hit()
        HelpHelper.navigateToHelpPage()
        let askTheCommunityButton = HelpHelper.askTheCommunity.waitUntil(.visible)
        XCTAssertTrue(askTheCommunityButton.isVisible)

        askTheCommunityButton.hit()
        HelpHelper.openInSafariButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://community.canvaslms.com/t5/Canvas-Question-Forum/bd-p/questions"))

        // MARK: Check "Submit a Feature Idea" button
        HelpHelper.returnToHelpPage(teacher: true)
        let submitAFeatureButton = HelpHelper.submitAFeatureIdea.waitUntil(.visible)
        XCTAssertTrue(submitAFeatureButton.isVisible)

        submitAFeatureButton.hit()
        HelpHelper.openInSafariButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("canvas-ideas-themes"))

        // MARK: Check "Training Services Portal" button
        HelpHelper.returnToHelpPage(teacher: true)
        let trainingServicesButton = HelpHelper.trainingServices.waitUntil(.visible)
        XCTAssertTrue(trainingServicesButton.isVisible)

        trainingServicesButton.hit()
        HelpHelper.openInSafariButton.hit()
        browserURL = SafariAppHelper.browserURL
        XCTAssertTrue(browserURL.contains("https://training-portal-beta-pdx.insproserv.net"))
    }
}
