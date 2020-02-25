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

        ModulesDetail.module(index: 0).tap()
        XCTAssertEqual(ModulesDetail.moduleItem(index: 0).label(), "Assignment One. Type: Assignment")
        XCTAssertEqual(ModulesDetail.moduleItem(index: 1).label(), "Assignment Two. Type: Assignment")
        ModulesDetail.moduleItem(index: 0).tap()

        AssignmentDetails.description("Assignment One").waitToExist()
        ModuleItemNavigation.nextButton.tap()
        AssignmentDetails.description("Assignment Two").waitToExist()
        ModuleItemNavigation.previousButton.tap()
        AssignmentDetails.description("Assignment One").waitToExist()

        ModuleItemNavigation.backButton.tap()
        ModulesDetail.moduleItem(index: 0).waitToExist()
    }

    func testLockedModulesDisplayCorrectly() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.modules.tap()

        XCTAssertEqual(ModulesDetail.module(index: 8).label(),
                       "Locked Module. Locked until January 1, 3000. Status: Locked")
        XCTAssertEqual(ModulesDetail.module(index: 9).label(),
                       "Previously Locked Module")
    }

    func testLaunchIntoDiscussionModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 2).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(labelContaining: "Teacher One").waitToExist()
        DiscussionDetails.replyButton.waitToExist()
    }

    func testLaunchIntoPageModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 3).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(labelContaining: "This is a page for testing modules").waitToExist()
    }

    func testLaunchIntoQuizModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 1).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(labelContaining: "This is the first quiz").waitToExist()
        Quiz.takeButton.waitToExist()
    }

    func testLaunchIntoFileModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 7).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(type: .image).waitToExist()
    }

    func testLaunchIntoExternalURLModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 4).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.webViews.staticTexts.firstElement.waitToExist(60)
    }

    func testLaunchIntoExternalToolModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 5).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        ExternalTool.launchButton.tap()
        ExternalTool.pageText("Instructure").waitToExist()
        ExternalTool.doneButton.tap()
    }

    func testLaunchIntoTextHeaderModuleItem() {
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 6).tap()
        ModulesDetail.moduleItem(index: 0).waitToExist()
    }
}
