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

class ListSelectionViewModelTests: XCTestCase {
    private var testee: ListSelectionViewModel!
    private var selectedItemListener: AnyCancellable?
    private var lastSelectedIndex: Int?

    override func setUp() {
        testee = ListSelectionViewModel(defaultSelection: 3)
        selectedItemListener = testee.selectedIndexPublisher.sink { [weak self] index in
            self?.lastSelectedIndex = index
        }

        super.setUp()
    }

    func testDefaultSelection() {
        testee.isSplitViewCollapsed.send(true)
        XCTAssertEqual(lastSelectedIndex, nil)
    }

    func testDefaultSelectionInSplitMode() {
        testee.isSplitViewCollapsed.send(false)
        XCTAssertEqual(lastSelectedIndex, 3)
    }

    func testCellTapRegisters() {
        testee.isSplitViewCollapsed.send(true)
        testee.cellTapped(at: 6)
        XCTAssertEqual(lastSelectedIndex, 6)
    }

    func testViewAppearanceClearsSelectionOutsideSplitView() {
        testee.isSplitViewCollapsed.send(true)
        testee.cellTapped(at: 6)
        testee.viewDidAppear()
        XCTAssertEqual(lastSelectedIndex, nil)
    }

    func testViewAppearanceResetsSelectionInSplitView() {
        testee.isSplitViewCollapsed.send(false)
        testee.cellTapped(at: 6)
        testee.viewDidAppear()
        XCTAssertEqual(lastSelectedIndex, 3)
    }

    func testSplitModeChangeUpdatesSelection() {
        // we start in portrait
        testee.isSplitViewCollapsed.send(true)
        XCTAssertEqual(lastSelectedIndex, nil)

        // rotate to landscape to split mode
        testee.isSplitViewCollapsed.send(false)
        XCTAssertEqual(lastSelectedIndex, 3)

        // rotate back to portrait
        testee.isSplitViewCollapsed.send(true)
        XCTAssertEqual(lastSelectedIndex, nil)
    }
}
