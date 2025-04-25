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

class ModuleItemSequenceViewControllerTests: CoreTestCase {
    lazy var controller = ModuleItemSequenceViewController.create(
        env: environment,
        courseID: "1",
        assetType: .moduleItem,
        assetID: "2",
        url: URLComponents(string: "/")!
    )

    override func setUp() {
        super.setUp()

        let prev = APIModuleItem.make(id: "1", module_id: "1", html_url: URL(string: "/prev"))
        let current = APIModuleItem.make(id: "2", module_id: "1", html_url: URL(string: "/current"))
        let next = APIModuleItem.make(id: "3", module_id: "2", html_url: URL(string: "/next"))
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: prev.id.value),
            value: .make(items: [.make(prev: nil, current: prev, next: current)])
        )
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: current.id.value),
            value: .make(items: [.make(prev: prev, current: current, next: next)])
        )
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: next.id.value),
            value: .make(items: [.make(prev: current, current: next, next: nil)])
        )
    }

    func testLayout() throws {
        let routerButton = UIBarButtonItem()
        controller.addNavigationButton(routerButton, side: .left)
        controller.view.layoutIfNeeded()
        var details = controller.pages.currentPage as! ModuleItemDetailsViewController
        XCTAssertEqual(details.courseID, "1")
        XCTAssertEqual(details.moduleID, "1")
        XCTAssertEqual(details.itemID, "2")
        XCTAssertFalse(controller.previousButton.isHidden)
        XCTAssertFalse(controller.nextButton.isHidden)

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

        let leftButton = UIBarButtonItemWithCompletion(title: "", actionHandler: {})
        let rightButton = UIBarButtonItem()
        details.title = "Title 1"
        details.navigationItem.title = "Title 2"
        details.navigationItem.leftBarButtonItems = [leftButton]
        details.navigationItem.rightBarButtonItems = [rightButton]
        details.navigationItem.leftItemsSupplementBackButton = true
        XCTAssertEqual(controller.title, "Title 1")
        XCTAssertEqual(controller.navigationItem.title, "Title 2")
        XCTAssertEqual(controller.navigationItem.leftBarButtonItems, [leftButton, routerButton])
        XCTAssertEqual(controller.navigationItem.rightBarButtonItems, [rightButton])
        XCTAssertTrue(controller.navigationItem.leftItemsSupplementBackButton)
    }

    func testNotAModuleItem() {
        let url = URLComponents(string: "/courses/1/files/1?origin=module_item_details")!
        router.mock(url) { [environment] in
            FileDetailsViewController
                .create(
                    context: .course("1"),
                    fileID: "1",
                    environment: environment
                )
        }
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .file, assetID: "1"),
            value: .make(items: [.make(current: nil)])
        )
        let controller = ModuleItemSequenceViewController.create(
            env: environment,
            courseID: "1",
            assetType: .file,
            assetID: "1",
            url: URLComponents(string: "/courses/1/files/1")!
        )
        controller.view.layoutIfNeeded()
        XCTAssertNotNil(controller.pages.currentPage as? FileDetailsViewController)
        XCTAssertTrue(controller.buttonsContainer.isHidden)
    }

    func testUnsupportedItem() {
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: "1"),
            value: .make(items: [.make(current: nil)])
        )
        let controller = ModuleItemSequenceViewController.create(
            env: environment,
            courseID: "1",
            assetType: .moduleItem,
            assetID: "1",
            url: URLComponents(string: "/unsupported-item")!
        )
        controller.view.layoutIfNeeded()
        let details = controller.pages.currentPage as! ExternalURLViewController
        XCTAssertEqual(details.name, "Unsupported Item")
        XCTAssertEqual(details.courseID, "1")
        XCTAssertTrue(details.authenticate)
    }

    func testOfflineMode() {
        _ = ModuleItem.save(.make(id: "item-id", pageId: "my-page"), forCourse: "1", in: databaseClient)
        let prev = APIModuleItem.make(id: "item-id", module_id: "1", html_url: URL(string: "/prev"), pageId: "my-page")
        let current = APIModuleItem.make(id: "2", module_id: "1", html_url: URL(string: "/current"))
        let next = APIModuleItem.make(id: "3", module_id: "2", html_url: URL(string: "/next"))
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: prev.id.value),
            value: .make(items: [.make(prev: nil, current: prev, next: current)])
        )
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: current.id.value),
            value: .make(items: [.make(prev: prev, current: current, next: next)])
        )
        api.mock(
            GetModuleItemSequenceRequest(courseID: "1", assetType: .moduleItem, assetID: next.id.value),
            value: .make(items: [.make(prev: current, current: next, next: nil)])
        )

        let offlineModeInteractorMock = OfflineModeInteractorMock(mockIsInOfflineMode: true)
        let controller = ModuleItemSequenceViewController.create(
            env: environment,
            courseID: "1",
            assetType: .page,
            assetID: "my-page",
            url: URLComponents(string: "")!,
            offlineModeInteractor: offlineModeInteractorMock
        )
        controller.view.layoutIfNeeded()
        let details = controller.pages.currentPage as! ModuleItemDetailsViewController
        XCTAssertEqual(details.courseID, "1")
        XCTAssertEqual(details.moduleID, "1")
        XCTAssertEqual(details.itemID, "item-id")
        XCTAssertTrue(controller.previousButton.isHidden)
        XCTAssertFalse(controller.nextButton.isHidden)
    }

    func test_setCurrentPage_stopWebViewPlayback() {
        let viewController = ModuleItemSequenceViewController()
        let playerViewController = MockViewController()
        viewController.pages.setCurrentPage(playerViewController)

        // WHEN
        viewController.setCurrentPage(UIViewController(), direction: .forward)

        // THEN
        XCTAssertTrue(playerViewController.stopWebViewPlaybackCalled)
    }
}

private class MockViewController: UIViewController {
    var stopWebViewPlaybackCalled = false

    override func pauseWebViewPlayback() {
        stopWebViewPlaybackCalled = true
    }
}
