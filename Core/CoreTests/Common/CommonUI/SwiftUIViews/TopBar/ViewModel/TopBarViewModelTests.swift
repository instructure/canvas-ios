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
        TopBarItemViewModel(id: "1", icon: .addAudioLine, label: Text(verbatim: "1")),
        TopBarItemViewModel(id: "2", icon: .addAudioLine, label: Text(verbatim: "2")),
        TopBarItemViewModel(id: "3", icon: .addAudioLine, label: Text(verbatim: "3"))
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
        XCTAssertEqual(testee.selectedItemId, "1")

        testee.selectedItemIndex = 1
        XCTAssertEqual(testee.selectedItemId, "2")
    }

    func testItemInfo() {
        let firstInfo = testee.itemInfo(for: testee.items[0])!
        XCTAssertTrue(firstInfo.isFirst)
        XCTAssertFalse(firstInfo.isLast)
        XCTAssertEqual(firstInfo.index, 0)

        let middleInfo = testee.itemInfo(for: testee.items[1])!
        XCTAssertFalse(middleInfo.isFirst)
        XCTAssertFalse(middleInfo.isLast)
        XCTAssertEqual(middleInfo.index, 1)

        let lastInfo = testee.itemInfo(for: testee.items[2])!
        XCTAssertFalse(lastInfo.isFirst)
        XCTAssertTrue(lastInfo.isLast)
        XCTAssertEqual(lastInfo.index, 2)
    }
}
