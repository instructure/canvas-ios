//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class CoreWebViewAccessibilityHelperTests: XCTestCase {

    var helper: CoreWebViewAccessibilityHelper!
    var containerView: UIView!
    var targetView: UIView!
    var siblingView1: UIView!
    var siblingView2: UIView!
    var viewController: UIViewController!
    var navigationController: UINavigationController!
    var tabBarController: UITabBarController!

    override func setUp() {
        super.setUp()
        helper = CoreWebViewAccessibilityHelper()

        // Create view hierarchy
        containerView = UIView()
        targetView = UIView()
        siblingView1 = UIView()
        siblingView2 = UIView()

        containerView.addSubview(targetView)
        containerView.addSubview(siblingView1)
        containerView.addSubview(siblingView2)

        // Create view controllers
        viewController = UIViewController()
        navigationController = UINavigationController(rootViewController: viewController)
        tabBarController = UITabBarController()
        tabBarController.viewControllers = [navigationController]
    }

    override func tearDown() {
        helper = nil
        containerView = nil
        targetView = nil
        siblingView1 = nil
        siblingView2 = nil
        viewController = nil
        navigationController = nil
        tabBarController = nil
        super.tearDown()
    }

    func test_setExclusiveAccessibility_withIsExclusiveTrue() {
        helper.setExclusiveAccessibility(
            for: targetView,
            isExclusive: true,
            viewController: viewController
        )

        XCTAssertTrue(siblingView1.accessibilityElementsHidden)
        XCTAssertTrue(siblingView2.accessibilityElementsHidden)
        XCTAssertFalse(targetView.accessibilityElementsHidden)
        XCTAssertTrue(navigationController.navigationBar.accessibilityElementsHidden)
        XCTAssertTrue(tabBarController.tabBar.accessibilityElementsHidden)
    }

    func test_setExclusiveAccessibility_withIsExclusiveFalse() {
        // First set exclusive to true
        helper.setExclusiveAccessibility(
            for: targetView,
            isExclusive: true,
            viewController: viewController
        )

        // Then restore accessibility
        helper.setExclusiveAccessibility(
            for: targetView,
            isExclusive: false,
            viewController: viewController
        )

        XCTAssertFalse(siblingView1.accessibilityElementsHidden)
        XCTAssertFalse(siblingView2.accessibilityElementsHidden)
        XCTAssertFalse(targetView.accessibilityElementsHidden)
        XCTAssertFalse(navigationController.navigationBar.accessibilityElementsHidden)
        XCTAssertFalse(tabBarController.tabBar.accessibilityElementsHidden)
    }

    func test_setExclusiveAccessibility_withNilViewController() {
        helper.setExclusiveAccessibility(
            for: targetView,
            isExclusive: true,
            viewController: nil
        )

        XCTAssertTrue(siblingView1.accessibilityElementsHidden)
        XCTAssertTrue(siblingView2.accessibilityElementsHidden)
        XCTAssertFalse(targetView.accessibilityElementsHidden)
    }

    func test_setExclusiveAccessibility_withViewControllerWithoutNavigationController() {
        let standaloneViewController = UIViewController()
        let standaloneTabBarController = UITabBarController()
        standaloneTabBarController.viewControllers = [standaloneViewController]

        helper.setExclusiveAccessibility(
            for: targetView,
            isExclusive: true,
            viewController: standaloneViewController
        )

        XCTAssertTrue(siblingView1.accessibilityElementsHidden)
        XCTAssertTrue(siblingView2.accessibilityElementsHidden)
        XCTAssertTrue(standaloneTabBarController.tabBar.accessibilityElementsHidden)
    }

    func test_setExclusiveAccessibility_withViewControllerWithoutTabBarController() {
        let standaloneViewController = UIViewController()
        let standaloneNavController = UINavigationController(rootViewController: standaloneViewController)

        helper.setExclusiveAccessibility(
            for: targetView,
            isExclusive: true,
            viewController: standaloneViewController
        )

        XCTAssertTrue(siblingView1.accessibilityElementsHidden)
        XCTAssertTrue(siblingView2.accessibilityElementsHidden)
        XCTAssertTrue(standaloneNavController.navigationBar.accessibilityElementsHidden)
    }

    func test_setExclusiveAccessibility_withNestedViewHierarchy() {
        let grandparentView = UIView()
        let parentView = UIView()
        let parentSibling = UIView()
        let grandparentSibling = UIView()

        grandparentView.addSubview(parentView)
        grandparentView.addSubview(grandparentSibling)
        parentView.addSubview(containerView)
        parentView.addSubview(parentSibling)

        helper.setExclusiveAccessibility(
            for: targetView,
            isExclusive: true,
            viewController: viewController
        )

        // Direct siblings should be hidden
        XCTAssertTrue(siblingView1.accessibilityElementsHidden)
        XCTAssertTrue(siblingView2.accessibilityElementsHidden)

        // Parent's siblings should be hidden
        XCTAssertTrue(parentSibling.accessibilityElementsHidden)

        // Grandparent's siblings should be hidden
        XCTAssertTrue(grandparentSibling.accessibilityElementsHidden)

        // Target view should remain accessible
        XCTAssertFalse(targetView.accessibilityElementsHidden)
    }

    func test_setExclusiveAccessibility_withViewWithoutSuperview() {
        let isolatedView = UIView()

        helper.setExclusiveAccessibility(
            for: isolatedView,
            isExclusive: true,
            viewController: viewController
        )

        XCTAssertTrue(navigationController.navigationBar.accessibilityElementsHidden)
        XCTAssertTrue(tabBarController.tabBar.accessibilityElementsHidden)
    }
}
