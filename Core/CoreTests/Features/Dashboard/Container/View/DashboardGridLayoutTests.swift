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
import XCTest

final class DashboardGridLayoutTests: XCTestCase {

    // MARK: - Row heights

    func test_rowHeights_shouldBeMaxHeightPerRow() {
        let cache = makeCache(itemHeights: [50, 100, 75, 30], columnCount: 2)

        XCTAssertEqual(cache.rowHeights, [100, 75])
    }

    func test_rowHeights_withIncompleteLastRow_shouldUseMaxOfAvailableItems() {
        let cache = makeCache(itemHeights: [50, 100, 40], columnCount: 2)

        XCTAssertEqual(cache.rowHeights, [100, 40])
    }

    func test_rowHeights_withSingleItem() {
        let cache = makeCache(itemHeights: [80], columnCount: 3)

        XCTAssertEqual(cache.rowHeights, [80])
    }

    func test_rowHeights_withNoItems() {
        let cache = makeCache(itemHeights: [], columnCount: 2)

        XCTAssertEqual(cache.rowHeights, [])
    }

    // MARK: - Row Y offsets

    func test_rowYOffsets_firstRowIsAlwaysZero() {
        let cache = makeCache(itemHeights: [50, 50, 50, 50], columnCount: 2)

        XCTAssertEqual(cache.rowYOffsets.first, 0)
    }

    func test_rowYOffsets_shouldAccumulateRowHeightsPlusSpacing() {
        let cache = makeCache(itemHeights: [100, 100, 75, 75], columnCount: 2, spacing: 10)

        XCTAssertEqual(cache.rowYOffsets, [0, 110])
    }

    func test_rowYOffsets_withThreeRows() {
        let cache = makeCache(itemHeights: [50, 60, 40, 80, 30, 70], columnCount: 2, spacing: 8)

        XCTAssertEqual(cache.rowYOffsets, [0, 68, 156])
    }

    // MARK: - Total size

    func test_totalSize_width_shouldFitAllColumnsWithSpacing() {
        let cache = makeCache(itemHeights: [50, 50], columnCount: 2, itemWidth: 100, spacing: 10)

        XCTAssertEqual(cache.totalSize.width, 210)
    }

    func test_totalSize_height_shouldSumRowHeightsPlusSpacing() {
        let cache = makeCache(itemHeights: [100, 100, 75, 75], columnCount: 2, itemWidth: 100, spacing: 10)

        XCTAssertEqual(cache.totalSize.height, 185)
    }

    func test_totalSize_withSingleRow_shouldHaveNoVerticalSpacing() {
        let cache = makeCache(itemHeights: [50, 60], columnCount: 2, itemWidth: 100, spacing: 10)

        XCTAssertEqual(cache.totalSize.height, 60)
    }

    func test_totalSize_withNoItems_shouldBeZero() {
        let cache = makeCache(itemHeights: [], columnCount: 2, itemWidth: 100, spacing: 10)

        XCTAssertEqual(cache.totalSize, CGSize(width: 210, height: 0))
    }

    // MARK: - Private helpers

    private func makeCache(
        itemHeights: [CGFloat],
        columnCount: Int = 2,
        itemWidth: CGFloat = 100,
        spacing: CGFloat = 8
    ) -> DashboardGridLayout.GridMetrics {
        DashboardGridLayout.GridMetrics.make(
            itemHeights: itemHeights,
            columnCount: columnCount,
            itemWidth: itemWidth,
            spacing: spacing
        )
    }
}
