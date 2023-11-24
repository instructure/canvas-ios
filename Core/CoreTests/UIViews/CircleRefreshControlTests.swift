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

@testable import Core
import TestsFoundation
import XCTest

class CircleRefreshControlTests: CoreTestCase {
    let scrollView = MockScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 800))
    let refreshControl = CircleRefreshControl()
    var refreshed = false

    func testColor() {
        refreshControl.color = .orange
        XCTAssertEqual(refreshControl.color, .orange)
        XCTAssertEqual(refreshControl.progressView.color, .orange)
    }

    func testRefresh() {
        scrollView.refreshControl = refreshControl
        refreshControl.didMoveToSuperview()

        let testViewController = UIViewController()
        testViewController.view = scrollView

        window.rootViewController = testViewController
        scrollView.contentOffset = .zero

        XCTAssertEqual(refreshControl.progressView.alpha, 0)
        XCTAssertEqual(refreshControl.isRefreshing, false)
        XCTAssertEqual(refreshControl.isAnimating, false)

        scrollView.contentOffset.y = -5
        XCTAssertEqual(refreshControl.progressView.alpha, refreshControl.progressView.progress!, accuracy: 0.01)
        XCTAssertEqual(refreshControl.isRefreshing, false)
        XCTAssertEqual(refreshControl.isAnimating, false)

        scrollView.contentOffset.y = -100
        refreshControl.beginRefreshing()
        XCTAssertEqual(refreshControl.progressView.alpha, 1)
        XCTAssertEqual(refreshControl.isRefreshing, true)
        XCTAssertEqual(refreshControl.isAnimating, true)

        refreshControl.endRefreshing()
        scrollView.contentOffset.y = 0

        RunLoop.main.run(until: Date().advanced(by: 2))
        drainMainQueue()

        XCTAssertEqual(refreshControl.progressView.alpha, 0)
        XCTAssertEqual(refreshControl.isRefreshing, false)
        XCTAssertEqual(refreshControl.isAnimating, false)

        scrollView.contentOffset.y = 32
        XCTAssertEqual(refreshControl.progressView.alpha, 0)
        XCTAssertEqual(refreshControl.isRefreshing, false)
        XCTAssertEqual(refreshControl.isAnimating, false)
    }

    class MockScrollView: UIScrollView {
        override var isDragging: Bool { true }
    }
}
