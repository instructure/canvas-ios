//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
import TestsFoundation
@testable import CoreUITests
@testable import Core

class ModulesE2ETests: CoreUITestCase {
    func testLaunchIntoAssignmentsAndNavigateModuleItems() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        XCTAssertEqual(ModuleList.item(section: 0, row: 0).label(), "assignment, Assignment One, 10 pts")
        XCTAssertEqual(ModuleList.item(section: 0, row: 1).label(), "assignment, Assignment Two, 10 pts")
        ModuleList.item(section: 0, row: 0).tap()

        AssignmentDetails.description("Assignment One").waitToExist()
        ModuleItemSequence.nextButton.tap()
        AssignmentDetails.description("Assignment Two").waitToExist()
        ModuleItemSequence.previousButton.tap()
        AssignmentDetails.description("Assignment One").waitToExist()

        NavBar.backButton.tap()
        ModuleList.item(section: 0, row: 0).waitToExist()
    }

    func testLockedModulesDisplayCorrectly() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.modules.tap()

        XCTAssertEqual(ModuleList.item(section: 8, row: 0).label(),
                       "file, run.jpg, locked")
        XCTAssertEqual(ModuleList.item(section: 9, row: 0).label(),
                       "file, run.jpg")
    }

    func testLaunchIntoDiscussionModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModuleList.item(section: 2, row: 0).tap()

        app.find(labelContaining: "Teacher One").waitToExist()
        XCTAssertEqual(NavBar.title.label(), "Discussion Details")
    }

    func testLaunchIntoPageModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModuleList.item(section: 3, row: 0).tap()

        app.find(labelContaining: "This is a page for testing modules").waitToExist()
    }

    func testLaunchIntoQuizModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()
        ModuleList.item(section: 1, row: 0).tap()

        app.find(labelContaining: "This is the first quiz").waitToExist()
        Quiz.takeButton.waitToExist()
    }

    func testLaunchIntoFileModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModuleList.item(section: 7, row: 0).tap()

        app.find(type: .image).waitToExist()
    }

    func testLaunchIntoExternalURLModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModuleList.item(section: 4, row: 0).tap()

        ExternalURL.openInButton.waitToExist()
    }

    func testLaunchIntoExternalToolModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModuleList.item(section: 5, row: 0).tap()

        ExternalTool.launchButton.tap()
        ExternalTool.pageText("Instructure").waitToExist()
        ExternalTool.doneButton.tap()
    }
}
