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

import Foundation
@testable import Core
import XCTest
@testable import TestsFoundation

class ModuleItemDetailsViewControllerTests: CoreTestCase {
    typealias AssetType = ModuleItemType

    class CurrentViewController: UIViewController {}
    class NextViewController: UIViewController {}
    class PreviousViewController: UIViewController {}

    var courseID = "1"
    var assetType: ModuleItemSequenceViewController.AssetType = .assignment
    var assetID: String = "2"
    var url = URLComponents(string: "/courses/1/assignments/2")!
    lazy var controller = ModuleItemSequenceViewController.create(
        courseID: "1",
        assetType: .moduleItem,
        assetID: "2",
        url: URLComponents(string: "/")!
    )

    override func setUp() {
        super.setUp()
        environment.mockStore = false

        let prev = APIModuleItem.make(id: "1", module_id: "1", html_url: URL(string: "/prev"))
        let current = APIModuleItem.make(id: "2", module_id: "1", html_url: URL(string: "/current"))
        let next = APIModuleItem.make(id: "3", module_id: "2", html_url: URL(string: "/next"))
        api.mock(
            GetModuleItemSequenceRequest(courseID: courseID, assetType: .moduleItem, assetID: prev.id.value),
            value: .make(items: [.make(prev: nil, current: prev, next: current)])
        )
        api.mock(
            GetModuleItemSequenceRequest(courseID: courseID, assetType: .moduleItem, assetID: current.id.value),
            value: .make(items: [.make(prev: prev, current: current, next: next)])
        )
        api.mock(
            GetModuleItemSequenceRequest(courseID: courseID, assetType: .moduleItem, assetID: next.id.value),
            value: .make(items: [.make(prev: current, current: next, next: nil)])
        )
    }

    func testLayout() throws {
        controller.view.layoutIfNeeded()
        var details = controller.pages.currentPage as! ModuleItemDetailsViewController
        XCTAssertEqual(details.courseID, "1")
        XCTAssertEqual(details.moduleID, "1")
        XCTAssertEqual(details.itemID, "2")
        XCTAssertFalse(controller.previousButton.isHidden)
        XCTAssertTrue(controller.previousButton.isHidden)

        controller.previousButton.sendActions(for: .primaryActionTriggered)
        details = controller.pages.currentPage as! ModuleItemDetailsViewController
        XCTAssertEqual(details.courseID, "1")
        XCTAssertEqual(details.moduleID, "1")
        XCTAssertEqual(details.itemID, "1")
        XCTAssertFalse(controller.nextButton.isHidden)
        XCTAssertTrue(controller.previousButton.isHidden)

        controller.nextButton.sendActions(for: .primaryActionTriggered)
        controller.nextButton.sendActions(for: .primaryActionTriggered)
        details = controller.pages.currentPage as! ModuleItemDetailsViewController
        XCTAssertEqual(details.courseID, "1")
        XCTAssertEqual(details.moduleID, "2")
        XCTAssertEqual(details.itemID, "3")
        XCTAssertTrue(controller.nextButton.isHidden)
        XCTAssertFalse(controller.previousButton.isHidden)

        let leftButton = UIBarButtonItem()
        let rightButton = UIBarButtonItem()
        details.title = "Title 1"
        details.navigationItem.title = "Title 2"
        details.navigationItem.leftBarButtonItems = [leftButton]
        details.navigationItem.rightBarButtonItems = [rightButton]
        XCTAssertEqual(controller.title, "Title 1")
        XCTAssertEqual(controller.navigationItem.title, "Title 2")
        XCTAssertEqual(details.navigationItem.leftBarButtonItems, [leftButton])
        XCTAssertEqual(details.navigationItem.rightBarButtonItems, [rightButton])
    }
}
