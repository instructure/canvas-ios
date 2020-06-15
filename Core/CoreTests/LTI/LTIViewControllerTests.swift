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
@testable import TestsFoundation
import XCTest
import SafariServices

class LTIViewControllerTests: CoreTestCase {
    func testLayout() {
        let tools = LTITools(id: "1")
        let controller = LTIViewController.create(tools: tools)
        var task = api.mock(tools.request, value: .make(name: "So Descriptive", url: URL(string: "/")!))
        task.paused = true

        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.nameLabel.text, "LTI Tool")
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertEqual(controller.titleSubtitleView.title, "External Tool")
        XCTAssertNil(controller.titleSubtitleView.subtitle)
        task.paused = false
        XCTAssertEqual(controller.nameLabel.text, "So Descriptive")

        task = api.mock(tools.request, value: .make())
        task.paused = true
        controller.openButton.sendActions(for: .primaryActionTriggered)
        XCTAssertFalse(controller.spinnerView.isHidden)
        XCTAssertFalse(controller.openButton.isEnabled)
        task.paused = false
        XCTAssertNotNil(router.presented as? SFSafariViewController)
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertTrue(controller.openButton.isEnabled)
    }

    func testName() {
        let tools = LTITools(id: "1")
        let controller = LTIViewController.create(tools: tools, name: "Fancy Tool")
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.nameLabel.text, "Fancy Tool")
    }

    func testCourseSubtitle() {
        let course = APICourse.make(id: "1", name: "Fancy Course")
        let tools = LTITools(context: .course(course.id.value))
        let controller = LTIViewController.create(tools: tools)
        api.mock(controller.courses!, value: course)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Fancy Course")
    }
}
