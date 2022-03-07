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

@testable import Core
import SwiftUI
import XCTest

class TopBarViewModelTests: XCTestCase {
    private var testee = TopBarViewModel(items: [
        TopBarItemViewModel(icon: .addAudioLine, label: Text(verbatim: "1")),
        TopBarItemViewModel(icon: .addAudioLine, label: Text(verbatim: "2")),
        TopBarItemViewModel(icon: .addAudioLine, label: Text(verbatim: "3")),
    ])

    func testSwiftUIUpdateTrigger() {
        var receivedIndexes: [Int] = []
        var viewModelIndexes: [Int] = []
        let subscription = testee.$selectedItemIndex.sink { selectedIndex in
            receivedIndexes.append(selectedIndex)
            viewModelIndexes.append(self.testee.selectedItemIndex)
        }

        testee.selectedItemIndex = 0
        testee.selectedItemIndex = 1
        testee.selectedItemIndex = 2

        XCTAssertEqual(receivedIndexes, [0, 0, 1, 2])
        XCTAssertEqual(viewModelIndexes, [0, 0, 0, 1])
        subscription.cancel()
    }

    func testSelectedItemIndexPublisher() {
        var receivedIndexes: [Int] = []
        var viewModelIndexes: [Int] = []
        let subscription = testee.selectedItemIndexPublisher.sink { selectedIndex in
            receivedIndexes.append(selectedIndex)
            viewModelIndexes.append(self.testee.selectedItemIndex)
        }

        testee.selectedItemIndex = 0
        testee.selectedItemIndex = 1
        testee.selectedItemIndex = 2

        XCTAssertEqual(receivedIndexes, [0, 0, 1, 2])
        XCTAssertEqual(viewModelIndexes, [0, 0, 1, 2])
        subscription.cancel()
    }

    func testSelectedItemId() {
        testee.items[1].id = "test"
        XCTAssertNil(testee.selectedItemId)

        testee.selectedItemIndex = 1
        XCTAssertEqual(testee.selectedItemId, "test")
    }
}
