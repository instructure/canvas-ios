//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import UIKit
@testable import Core
import WebKit

class UIViewControllerExtensionsTests: XCTestCase {
    class MockController: UIViewController {
        var dismissAnimated: Bool?
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissAnimated = flag
        }
    }

    func testAddCancelButton() {
        let controller = UIViewController()
        controller.addCancelButton()
        XCTAssertEqual(controller.navigationItem.rightBarButtonItems?.first?.action, #selector(controller.dismissDoneButton))
    }

    func testAddDoneButton() {
        let controller = UIViewController()
        controller.addDoneButton(side: .left)
        XCTAssertEqual(controller.navigationItem.leftBarButtonItems?.first?.action, #selector(controller.dismissDoneButton))
    }

    func testDismissDoneButton() {
        let controller = MockController()
        controller.dismissDoneButton()
        XCTAssertEqual(controller.dismissAnimated, true)
    }

    func testLoadFromStoryboard() {
        XCTAssertNotNil(LoadingViewController.loadFromStoryboard())
    }

    func testTopMostViewController() {
        let vc = UIViewController()
        XCTAssertEqual(vc.topMostViewController(), vc)
    }

    func testEmbed() {
        let parent = UIViewController()
        let child = UIViewController()
        parent.embed(child, in: parent.view)
        XCTAssertEqual(child.parent, parent)
        XCTAssertEqual(child.view.superview, parent.view)
        XCTAssertEqual(parent.view.constraints.count, 4)

        child.unembed()
        XCTAssertNil(child.parent)
        XCTAssertNil(child.view.superview)
        XCTAssertEqual(parent.view.constraints.count, 0)
    }

    func testIsInSplitViewDetail() {
        let controller = UIViewController()
        let split = UISplitViewController()
        split.viewControllers = [UIViewController(), UINavigationController(rootViewController: controller)]
        XCTAssertTrue(controller.isInSplitViewDetail)

        split.viewControllers = [UINavigationController(rootViewController: controller)]
        XCTAssertFalse(controller.isInSplitViewDetail)

        split.viewControllers = [UIViewController(), controller]
        XCTAssertFalse(controller.isInSplitViewDetail)

        let parent = UIViewController()
        parent.embed(controller, in: parent.view)
        split.viewControllers = [UIViewController(), UINavigationController(rootViewController: parent)]
        XCTAssertTrue(controller.isInSplitViewDetail)
    }

    func testDisplayModeButtonItem() {
        let controller = UIViewController()
        XCTAssertNil(controller.splitDisplayModeButtonItem)
        let split = UISplitViewController()
        split.viewControllers = [controller]
        XCTAssertNotNil(controller.splitDisplayModeButtonItem)
    }

    func test_stopWebViewPlayback() {
        let parentViewController = UIViewController()

        let mockWebView = MockWKWebView()
        let containerView = UIView()
        let mockNestedWebView = MockWKWebView()

        parentViewController.view.addSubview(mockWebView)
        parentViewController.view.addSubview(containerView)
        containerView.addSubview(mockNestedWebView)

        // WHEN
        parentViewController.pauseWebViewPlayback()

        // THEN
        XCTAssertTrue(mockWebView.pauseAllMediaPlaybackCalled)
        XCTAssertTrue(mockNestedWebView.pauseAllMediaPlaybackCalled)
    }
}

private class MockWKWebView: WKWebView {
    var pauseAllMediaPlaybackCalled = false

    override func pauseAllMediaPlayback(
        completionHandler: (@MainActor @Sendable () -> Void)? = nil
    ) {
        pauseAllMediaPlaybackCalled = true
    }
}
