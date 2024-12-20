//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Combine
import Core
import XCTest

class SplitViewModeObserverTests: XCTestCase {
    private var testee: SplitViewModeObserver!
    private var isCollapsedListener: AnyCancellable?
    private var isCollaped: Bool?
    private let mockSplitController = MockUISplitViewController()

    override func setUp() {
        isCollaped = nil
        testee = SplitViewModeObserver()
        isCollapsedListener = testee.isCollapsed.sink { [weak self] isCollaped in
            self?.isCollaped = isCollaped
        }

        super.setUp()
    }

    func testDefaultState() {
        XCTAssertEqual(isCollaped, true)
    }

    func testInitialPortraitState() {
        mockSplitController.mockIsCollapsed = true
        testee.splitViewController = mockSplitController
        XCTAssertEqual(isCollaped, true)
    }

    func testInitialLandscapeState() {
        mockSplitController.mockIsCollapsed = false
        testee.splitViewController = mockSplitController
        XCTAssertEqual(isCollaped, false)
    }

    func testPortraitRotatedToLandscapeState() {
        mockSplitController.mockIsCollapsed = true
        testee.splitViewController = mockSplitController
        mockSplitController.mockIsCollapsed = false
        NotificationCenter.default.post(name: UIViewController.showDetailTargetDidChangeNotification, object: mockSplitController)
        XCTAssertEqual(isCollaped, false)
    }
}

private class MockUISplitViewController: UISplitViewController {
    public override var isCollapsed: Bool { mockIsCollapsed }
    public var mockIsCollapsed: Bool = true
}
