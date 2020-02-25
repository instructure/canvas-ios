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
import TestsFoundation

class CircleRefreshControlTests: CoreTestCase {
    let scrollView = MockScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 800))
    let refreshControl = CircleRefreshControl()
    var refreshed = false

    func testColor() {
        refreshControl.color = .orange
        XCTAssertEqual(refreshControl.color, .orange)
        XCTAssertEqual(refreshControl.tintColor, .orange)
        XCTAssertEqual(refreshControl.progressView.color, .orange)
    }

    func testRefresh() {
        XCTAssertNil(refreshControl.progressView.superview)
        XCTAssertEqual(refreshControl.isRefreshing, false)

        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .primaryActionTriggered)
        XCTAssertEqual(refreshControl.progressView.superview, scrollView)
        refreshControl.beginRefreshing()
        XCTAssertEqual(refreshControl.isRefreshing, true)
        XCTAssertEqual(refreshControl.progressView.alpha, 1)
        XCTAssertEqual(scrollView.contentOffset.y, -64)

        refreshControl.endRefreshing()
        XCTAssertEqual(refreshControl.isRefreshing, false)
        XCTAssertEqual(refreshControl.progressView.alpha, 0)
        refreshControl.progressView.alpha = 0.5
        refreshControl.endRefreshing()
        XCTAssertEqual(refreshControl.progressView.alpha, 0.5)

        scrollView.contentOffset.y = 0
        scrollView.contentOffset.y = -16
        XCTAssertEqual(refreshed, false)
        XCTAssertEqual(refreshControl.isRefreshing, false)
        XCTAssertEqual(refreshControl.progressView.alpha, 0.5)
        XCTAssertEqual(refreshControl.progressView.progress, 0.25)

        scrollView.contentOffset.y = -32
        XCTAssertEqual(refreshed, false)
        XCTAssertEqual(refreshControl.isRefreshing, false)
        XCTAssertEqual(refreshControl.progressView.alpha, 1)
        XCTAssertEqual(refreshControl.progressView.progress, 0.5)

        scrollView.contentOffset.y = -65
        XCTAssertEqual(refreshed, true)
        XCTAssertEqual(refreshControl.isRefreshing, true)
        XCTAssertEqual(refreshControl.progressView.alpha, 1)
        XCTAssertEqual(refreshControl.progressView.progress, nil)

        scrollView.contentOffset.y = 0
        XCTAssertEqual(scrollView.contentOffset.y, 0)
        scrollView.contentOffset.y = -32
        XCTAssertEqual(scrollView.contentOffset.y, -64)

        refreshControl.endRefreshing()
        XCTAssertEqual(refreshControl.isRefreshing, false)
        scrollView.contentOffset.y = -80
        XCTAssertEqual(refreshControl.isRefreshing, false)
        scrollView.contentOffset.y = 0
        scrollView.contentOffset.y = -80
        XCTAssertEqual(refreshControl.isRefreshing, true)
    }

    func testParent() {
        scrollView.refreshControl = refreshControl
        let parent = UIView()
        parent.addSubview(refreshControl)
        XCTAssertNil(refreshControl.progressView.superview)
        XCTAssertNil(refreshControl.offsetObservation)
    }

    func refresh(_ sender: CircleRefreshControl) {
        XCTAssertEqual(sender, refreshControl)
        refreshed = true
    }

    class MockScrollView: UIScrollView {
        override var isDragging: Bool { true }
    }
}
