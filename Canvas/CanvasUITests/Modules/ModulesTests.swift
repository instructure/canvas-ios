//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

class ModulesTests: CanvasUITests {

    func testLaunchIntoAssignmentsAndNavigateModuleItems() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 0).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        AssignmentDetails.description("Assignment One").waitToExist()
        ModuleItemNavigation.nextButton.tap()
        AssignmentDetails.description("Assignment Two").waitToExist()
        ModuleItemNavigation.previousButton.tap()
        AssignmentDetails.description("Assignment One").waitToExist()

        ModuleItemNavigation.backButton.tap()
        XCTAssertEqual(ModulesDetail.moduleItem(index: 0).label, "Assignment One. Type: Assignment")
        XCTAssertEqual(ModulesDetail.moduleItem(index: 1).label, "Assignment Two. Type: Assignment")
    }

    func testLaunchIntoDiscussionModuleItem() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 2).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(labelContaining: "Teacher One").waitToExist()
        app.find(id: "discussion-reply").waitToExist()
    }

    func testLaunchIntoPageModuleItem() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 3).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(labelContaining: "This is a page for testing modules").waitToExist()
    }

    func testLaunchIntoQuizModuleItem() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 1).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(labelContaining: "This is the first quiz").waitToExist()
        app.find(labelContaining: "Take Quiz").waitToExist()
    }

    func testLaunchIntoFileModuleItem() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 7).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        app.find(type: .image).waitToExist()
    }

    func testLaunchIntoExternalURLModuleItem() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 4).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        XCUIElementWrapper(app.webViews.staticTexts.firstMatch).waitToExist()
    }

    func testLaunchIntoExternalToolModuleItem() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 5).tap()
        ModulesDetail.moduleItem(index: 0).tap()

        ExternalTool.launchButton.tap()
        ExternalTool.pageText("Instructure").waitToExist()
        ExternalTool.doneButton.tap()
    }

    func testLaunchIntoTextHeaderModuleItem() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.modules.tap()

        ModulesDetail.module(index: 6).tap()
        ModulesDetail.moduleItem(index: 0).waitToExist()
    }
}
