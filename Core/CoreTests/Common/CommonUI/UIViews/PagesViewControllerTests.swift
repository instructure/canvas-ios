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

import XCTest
@testable import Core

class PagesViewControllerTests: CoreTestCase {
    lazy var controller: PagesViewController = {
        let controller = PagesViewController()
        controller.currentPage.title = "0"
        controller.dataSource = self
        controller.delegate = self
        return controller
    }()

    var currentPage: UIViewController?
    var visiblePages: [UIViewController] = []
    var visibleTitles: [Int] {
        visiblePages.compactMap { $0.title.flatMap { Int($0) } }
    }

    func testScrolling() {
        controller.view.frame = UIScreen.main.bounds
        controller.view.layoutIfNeeded()
        let scroll = controller.scrollView
        let width = scroll.frame.width
        scroll.delegate?.scrollViewWillBeginDragging?(scroll)
        controller.view.layoutIfNeeded()
        scroll.delegate?.scrollViewDidScroll?(scroll)
        XCTAssertEqual(visibleTitles, [ 0 ])
        scroll.contentOffset.x = width * 1.5
        scroll.delegate?.scrollViewDidScroll?(scroll)
        XCTAssertEqual(visibleTitles, [ 0, 1 ])

        // same values won't trigger another isShowing delegate call
        visiblePages = []
        scroll.contentOffset.x = width * 1.75
        scroll.delegate?.scrollViewDidScroll?(scroll)
        XCTAssertEqual(visibleTitles, [])

        var target = CGPoint(x: width * 2, y: 0)
        scroll.delegate?.scrollViewWillEndDragging?(scroll, withVelocity: .zero, targetContentOffset: &target)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(currentPage?.title, "1")

        scroll.semanticContentAttribute = .forceRightToLeft
        scroll.delegate?.scrollViewWillBeginDragging?(scroll)
        controller.view.layoutIfNeeded()
        scroll.contentOffset.x = width * 1.8
        scroll.delegate?.scrollViewDidScroll?(scroll)
        XCTAssertEqual(visibleTitles, [ 1, 0 ])

        target = CGPoint(x: width * 2, y: 0)
        scroll.delegate?.scrollViewWillEndDragging?(scroll, withVelocity: .zero, targetContentOffset: &target)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(currentPage?.title, "0")

        scroll.semanticContentAttribute = .unspecified
        scroll.delegate?.scrollViewWillBeginDragging?(scroll)
        controller.view.layoutIfNeeded()
        scroll.contentOffset.x = width * 0.5
        scroll.delegate?.scrollViewDidScroll?(scroll)
        XCTAssertEqual(visibleTitles, [ -1, 0 ])

        target = CGPoint(x: 0, y: 0)
        scroll.delegate?.scrollViewWillEndDragging?(scroll, withVelocity: .zero, targetContentOffset: &target)
        controller.view.layoutIfNeeded()
        XCTAssertEqual(currentPage?.title, "-1")
    }

    func testAccessibilityScroll() {
        controller.view.frame = UIScreen.main.bounds
        controller.view.layoutIfNeeded()

        XCTAssertTrue(controller.accessibilityScroll(.left))
        XCTAssertEqual(currentPage?.title, "1")
        XCTAssertTrue(controller.accessibilityScroll(.right))
        XCTAssertEqual(currentPage?.title, "0")
        XCTAssertTrue(controller.accessibilityScroll(.up))
        XCTAssertEqual(currentPage?.title, "1")
        XCTAssertTrue(controller.accessibilityScroll(.down))
        XCTAssertEqual(currentPage?.title, "0")
        XCTAssertTrue(controller.accessibilityScroll(.previous))
        XCTAssertEqual(currentPage?.title, "-1")
        XCTAssertTrue(controller.accessibilityScroll(.next))
        XCTAssertEqual(currentPage?.title, "0")

        controller.view.semanticContentAttribute = .forceRightToLeft
        XCTAssertTrue(controller.accessibilityScroll(.left))
        XCTAssertEqual(currentPage?.title, "-1")
        XCTAssertTrue(controller.accessibilityScroll(.right))
        XCTAssertEqual(currentPage?.title, "0")
        XCTAssertTrue(controller.accessibilityScroll(.up))
        XCTAssertEqual(currentPage?.title, "1")
        XCTAssertTrue(controller.accessibilityScroll(.down))
        XCTAssertEqual(currentPage?.title, "0")
        XCTAssertTrue(controller.accessibilityScroll(.previous))
        XCTAssertEqual(currentPage?.title, "-1")
        XCTAssertTrue(controller.accessibilityScroll(.next))
        XCTAssertEqual(currentPage?.title, "0")

        controller.dataSource = nil
        XCTAssertFalse(controller.accessibilityScroll(.left))
    }

    func testSetCurrentPage() {
        controller.view.frame = UIScreen.main.bounds
        controller.view.layoutIfNeeded()
        let scroll = controller.scrollView

        let one = UIViewController()
        one.title = "1"
        let two = UIViewController()
        two.title = "2"

        controller.setCurrentPage(one)
        XCTAssertEqual(controller.currentPage, one)
        XCTAssertEqual(controller.scrollView.subviews.count, 1)

        scroll.delegate?.scrollViewWillBeginDragging?(scroll)
        controller.setCurrentPage(two, direction: .forward)
        XCTAssertEqual(controller.currentPage, two)
        XCTAssertEqual(controller.scrollView.subviews.count, 2)

        controller.setCurrentPage(one, direction: .reverse)
        XCTAssertEqual(controller.currentPage, one)
        XCTAssertEqual(controller.scrollView.subviews.count, 2)
    }
}

extension PagesViewControllerTests: PagesViewControllerDataSource, PagesViewControllerDelegate {
    func pagesViewController(_ pages: PagesViewController, pageBefore viewController: UIViewController) -> UIViewController? {
        let controller = UIViewController()
        controller.title = viewController.title.flatMap({ Int($0) }).map({ String($0 - 1) })
        return controller
    }

    func pagesViewController(_ pages: PagesViewController, pageAfter viewController: UIViewController) -> UIViewController? {
        let controller = UIViewController()
        controller.title = viewController.title.flatMap({ Int($0) }).map({ String($0 + 1) })
        return controller
    }

    func pagesViewController(_ pages: PagesViewController, isShowing list: [UIViewController]) {
        visiblePages = list
    }

    func pagesViewController(_ pages: PagesViewController, didTransitionTo page: UIViewController) {
        currentPage = page
    }
}
