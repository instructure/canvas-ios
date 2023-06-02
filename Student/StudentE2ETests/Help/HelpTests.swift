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
        Dashboard.profileButton.tap()
        let helpButton = Profile.helpButton.waitToExist()
        XCTAssertTrue(helpButton.isVisible)

        helpButton.tap()

        // MARK: Check visibility of all buttons
        let searchTheCanvasGuidesButton = Help.searchTheCanvasGuides.waitToExist()
        XCTAssertTrue(searchTheCanvasGuidesButton.isVisible)
        let askYourInstructorButton = Help.askYourInstructor.waitToExist()
        XCTAssertTrue(askYourInstructorButton.isVisible)
        let reportAProblemButton = Help.reportAProblem.waitToExist()
        XCTAssertTrue(reportAProblemButton.isVisible)
        let covid19Button = Help.covid19.waitToExist()
        XCTAssertTrue(covid19Button.isVisible)
        let videoConferencingGuidesButton = Help.videoConferencingGuides.waitToExist()
        XCTAssertTrue(videoConferencingGuidesButton.isVisible)
        let submitAFeatureButton = Help.submitAFeatureIdea.waitToExist()
        XCTAssertTrue(submitAFeatureButton.isVisible)

        searchTheCanvasGuidesButton.tap()
        let browserURL = Help.browserURL
        XCTAssertEqual(browserURL, "https://community.canvaslms.com/t5/Canvas-Guides/ct-p/canvas_guides")
    }
}
