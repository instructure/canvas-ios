//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core

class ModulesTests: CoreUITestCase {
    override func setUp() {
        super.setUp()
        mockBaseRequests()
    }

    func testUnlockModuleItemWithPrerequisiteModule() {
        var item1 = APIModuleItem.make(
            id: "1",
            module_id: "1",
            title: "Page 1",
            content: .page("page-1"),
            html_url: URL(string: "https://canvas.instructure.com/api/v1/courses/1/modules/items/1")!,
            url: URL(string: "https://canvas.example.edu/api/v1/courses/1/pages/page-1"),
            completion_requirement: .make(type: .must_view, completed: false)
        )
        mockData(GetUserProfileRequest(userID: "self"), value: APIProfile.make())
        mockData(GetModulesRequest(courseID: "1", include: []), value: [
            .make(id: "1", name: "Module 1", position: 1, prerequisite_module_ids: [], state: .unlocked),
            .make(id: "2", name: "Module 2", position: 2, prerequisite_module_ids: ["1"], state: .locked),
        ])
        mockData(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details, .mastery_paths]), value: [
            item1,
        ])
        mockData(GetModuleItemsRequest(courseID: "1", moduleID: "2", include: [.content_details, .mastery_paths]), value: [
            .make(
                id: "2",
                module_id: "2",
                title: "Page 2",
                content: .page("page-2"),
                html_url: URL(string: "https://canvas.instructure.com/api/v1/courses/1/modules/items/2")!,
                content_details: .make(locked_for_user: true, lock_explanation: "This item is part of a prereq module")
            ),
        ])
        mockData(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: "1"),
            value: APIModuleItemSequence(
                items: [.init(prev: nil, current: .make(id: "1", module_id: "1"), next: nil)],
                modules: []
            )
        )
        mockData(GetModuleItemRequest(courseID: "1", moduleID: "1", itemID: "1", include: [.content_details]), value: item1)
        mockData(GetPageRequest(context: .course("1"), url: "page-1"), value: .make(body: "hello", html_url: URL(string: "/courses/1/pages/page-1")!, url: "page-1"))
        mockData(PostMarkModuleItemRead(courseID: "1", moduleID: "1", moduleItemID: "1"))
        mockData(GetTabsRequest(context: .course("1")), value: [APITab.make(id: "modules")])
        show("courses/1/modules")
        ModuleList.module(section: 0).waitToExist()
        ModuleList.module(section: 1).waitToExist()
        XCTAssertEqual(ModuleList.item(section: 1, row: 0).label(), "page, Page 2, locked")
        item1.completion_requirement?.completed = true
        mockData(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details, .mastery_paths]), value: [
            item1,
        ])
        mockData(GetModuleItemsRequest(courseID: "1", moduleID: "2", include: [.content_details, .mastery_paths]), value: [
            .make(
                id: "2",
                module_id: "2",
                title: "Page 2",
                content: .page("page-2"),
                url: URL(string: "https://canvas.instructure.com/api/v1/courses/1/pages/page-2")!,
                content_details: .make(locked_for_user: false)
            ),
        ])
        mockData(GetModulesRequest(courseID: "1", include: []), value: [
            .make(id: "1", name: "Module 1", position: 1, prerequisite_module_ids: [], state: .unlocked),
            .make(id: "2", name: "Module 2", position: 2, prerequisite_module_ids: ["1"], state: .unlocked),
        ])
        ModuleList.item(section: 0, row: 0).tap()
        app.webViews.staticTexts.matching(label: "hello").firstElement.waitToExist(20)
        NavBar.backButton.tap()
        XCTAssertEqual(ModuleList.item(section: 1, row: 0).label(), "page, Page 2")
        XCTAssertTrue(ModuleList.item(section: 1, row: 0).isEnabled)
    }
}
