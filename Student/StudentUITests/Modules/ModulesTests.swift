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
@testable import CoreUITests

class ModulesTests: StudentUITestCase {
    override func setUp() {
        super.setUp()
        mockBaseRequests()
    }

    func testUnlockModuleItemWithPrerequisiteModule() {
        mockData(GetModulesRequest(courseID: "1", include: [.items], perPage: 99), value: [
            .make(id: "1", name: "Module 1", position: 1, prerequisite_module_ids: [], state: .unlocked),
            .make(id: "2", name: "Module 2", position: 2, prerequisite_module_ids: ["1"], state: .locked),
        ])
        mockData(GetModuleItemsRequest(courseID: "1", moduleID: "1", include: [.content_details, .mastery_paths], perPage: 99), value: [
            .make(
                id: "1",
                module_id: "1",
                title: "Page 1",
                content: .page("page-1"),
                url: URL(string: "https://canvas.instructure.com/api/v1/courses/1/pages/page-1")!,
                completion_requirement: .make(type: .must_view, completed: false)
            ),
        ])
        mockData(GetModuleItemsRequest(courseID: "1", moduleID: "2", include: [.content_details, .mastery_paths], perPage: 99), value: [
            .make(
                id: "2",
                module_id: "2",
                title: "Page 2",
                content: .page("page-2"),
                url: URL(string: "https://canvas.instructure.com/api/v1/courses/1/pages/page-2")!,
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
        mockData(GetPageRequest(context: ContextModel(.course, id: "1"), url: "page-1"), value: .make())
        mockData(PostMarkModuleItemRead(courseID: "1", moduleID: "1", moduleItemID: "1"))
        show("courses/1/modules")
        XCTAssertEqual(Modules.module(index: 0).label(), "Module 1")
        XCTAssertEqual(Modules.module(index: 1).label(), "Module 2. Status: Locked")
        Modules.module(index: 1).tap()
        app.find(labelContaining: "PREREQUISITE MODULES").waitToExist()
        XCTAssertEqual(app.find(id: "module_cell_0_0").label(), "Module 1")
        XCTAssertEqual(ModulesDetail.moduleItem(index: 0).label(), "Page 2. Type: Page. Status: Locked")
        XCTAssertFalse(ModulesDetail.moduleItem(index: 0).isEnabled)
        mockData(GetModuleItemsRequest(courseID: "1", moduleID: "2", include: [.content_details, .mastery_paths], perPage: 99), value: [
            .make(
                id: "2",
                module_id: "2",
                title: "Page 2",
                content: .page("page-2"),
                url: URL(string: "https://canvas.instructure.com/api/v1/courses/1/pages/page-2")!,
                content_details: .make(locked_for_user: false)
            ),
        ])
        mockData(GetModulesRequest(courseID: "1", include: [.items], perPage: 99), value: [
            .make(id: "1", name: "Module 1", position: 1, prerequisite_module_ids: [], state: .unlocked),
            .make(id: "2", name: "Module 2", position: 2, prerequisite_module_ids: ["1"], state: .unlocked),
        ])
        ModulesDetail.module(index: 0).tap()
        ModulesDetail.moduleItem(index: 0).tap()
        NavBar.backButton(label: "Module 1").waitToExist(60)
        NavBar.backButton(label: "Module 1").tap()
        NavBar.backButton(label: "Module 2").tap()
        app.find(label: "Page 2. Type: Page").waitToExist()
        XCTAssertEqual(ModulesDetail.moduleItem(index: 0).label(), "Page 2. Type: Page")
        XCTAssertTrue(ModulesDetail.moduleItem(index: 0).isEnabled)
    }
}
