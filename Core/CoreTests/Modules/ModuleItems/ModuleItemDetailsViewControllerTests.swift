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
    lazy var controller = ModuleItemDetailsViewController.create(courseID: "1", moduleID: "2", itemID: "3")

    override func setUp() {
        super.setUp()
        environment.mockStore = false
    }

    func testLayout() {
        router.mock("/courses/1/files/2?origin=module_item_details") {
            FileDetailsViewController.create(context: ContextModel(.course, id: "1"), fileID: "2")
        }
        api.mock(controller.store, value: .make(
            id: "3",
            content: .file("2"),
            url: URL(string: "/courses/1/files/2")!
        ))
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.errorView.isHidden)
        XCTAssertFalse(controller.container.isHidden)
        XCTAssertNotNil(controller.children.first as? FileDetailsViewController)
    }

    func testError() {
        api.mock(controller.store, error: NSError.internalError())
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.errorView.isHidden)
        XCTAssertTrue(controller.container.isHidden)

        api.mock(controller.store, value: .make(id: "3"))
        controller.errorView.retryButton.sendActions(for: .primaryActionTriggered)
        XCTAssertTrue(controller.errorView.isHidden)
        XCTAssertFalse(controller.container.isHidden)
    }

    func testExternalURL() {
        api.mock(controller.store, value: .make(
            id: "3",
            title: "URL Item Title",
            content: .externalURL(URL(string: "https://apple.com")!)
        ))
        controller.view.layoutIfNeeded()
        let details = controller.children.first as! ExternalURLViewController
        XCTAssertEqual(details.name, "URL Item Title")
        XCTAssertEqual(details.url, URL(string: "https://apple.com"))
        XCTAssertEqual(details.courseID, "1")
    }

    func testExternalTool() {
        api.mock(controller.store, value: .make(
            id: "3",
            title: "LTI Item Title",
            content: .externalTool("5", URL(string: "https://lti.app")!)
        ))
        controller.view.layoutIfNeeded()
        let details = controller.children.first as! LTIViewController
        XCTAssertEqual(details.tools.context.contextType, .course)
        XCTAssertEqual(details.tools.context.id, "1")
        XCTAssertEqual(details.tools.id, "5")
        XCTAssertEqual(details.tools.launchType, .module_item)
        XCTAssertEqual(details.tools.moduleID, "2")
        XCTAssertEqual(details.tools.moduleItemID, "3")
        XCTAssertEqual(details.name, "LTI Item Title")
    }
}
