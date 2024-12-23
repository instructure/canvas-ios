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
        let tools = LTITools(id: "1", isQuizLTI: nil)
        let controller = LTIViewController.create(env: environment, tools: tools)
        var task = api.mock(tools.request, value: .make(name: "So Descriptive", url: .make()))
        task.suspend()

        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.nameLabel.text, "LTI Tool")
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertEqual(controller.titleSubtitleView.title, "External Tool")
        XCTAssertNil(controller.titleSubtitleView.subtitle)
        task.resume()
        XCTAssertEqual(controller.nameLabel.text, "So Descriptive")

        task = api.mock(tools.request, value: .make())
        task.suspend()
        controller.openButton.sendActions(for: .primaryActionTriggered)
        XCTAssertFalse(controller.spinnerView.isHidden)
        XCTAssertFalse(controller.openButton.isEnabled)
        task.resume()
        XCTAssertNotNil(router.presented as? SFSafariViewController)
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertTrue(controller.openButton.isEnabled)
    }

    func testName() {
        let tools = LTITools(env: environment, id: "1", isQuizLTI: nil)
        let controller = LTIViewController.create(env: environment, tools: tools, name: "Fancy Tool")
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.nameLabel.text, "Fancy Tool")
    }

    func testCourseSubtitle() {
        let course = APICourse.make(id: "1", name: "Fancy Course")
        let tools = LTITools(env: environment, context: .course(course.id.value), isQuizLTI: nil)
        let controller = LTIViewController.create(env: environment, tools: tools)
        api.mock(controller.courses!, value: course)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.titleSubtitleView.subtitle, "Fancy Course")
    }

    func testTextsWhenIsQuizLTI() {
        let controller = LTIViewController.create(env: environment, tools: .init(isQuizLTI: true))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.descriptionLabel.text?.lowercased().contains("quiz"), true)
        XCTAssertEqual(controller.openButton.titleLabel?.text?.lowercased().contains("quiz"), true)
    }

    func testTextsWhenIsNotQuizLTI() {
        let controller = LTIViewController.create(env: environment, tools: .init(isQuizLTI: false))
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.descriptionLabel.text?.lowercased().contains("quiz"), false)
        XCTAssertEqual(controller.openButton.titleLabel?.text?.lowercased().contains("quiz"), false)
    }
}
