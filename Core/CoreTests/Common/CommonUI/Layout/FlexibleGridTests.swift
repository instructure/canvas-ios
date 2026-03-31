//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import SwiftUI
import XCTest
@testable import Core

final class FlexibleGridTests: XCTestCase {

    // MARK: - sizeThatFits — single row

    func test_sizeThatFits_singleItem_occupiesOneRow() {
        let size = measure(items: 1, itemSize: CGSize(width: 50, height: 50), containerWidth: 300)

        XCTAssertEqual(size.height, 50)
    }

    func test_sizeThatFits_itemsFitInOneRow_producesOneRowHeight() {
        // 3 items × 50 + 2 gaps × 8 = 166 ≤ 300 → all fit in one row
        let size = measure(items: 3, itemSize: CGSize(width: 50, height: 50), containerWidth: 300)

        XCTAssertEqual(size.height, 50)
    }

    func test_sizeThatFits_usesProposedWidthAsContentWidth() {
        let size = measure(items: 3, itemSize: CGSize(width: 50, height: 50), containerWidth: 300)

        XCTAssertEqual(size.width, 300)
    }

    // MARK: - sizeThatFits — row wrapping

    func test_sizeThatFits_fourItemsWrapToTwoRows() {
        // columnCount(itemWidth:50, minimumSpacing:8, maxWidth:160):
        //   2×50 + 1×8 = 108 ≤ 160 → count=2
        //   3×50 + 2×8 = 166 > 160  → stop
        // 4 items / 2 cols = 2 rows → height = 2×50 + 1×8 = 108
        let size = measure(items: 4, itemSize: CGSize(width: 50, height: 50), containerWidth: 160)

        XCTAssertEqual(size.height, 108)
    }

    func test_sizeThatFits_sixItemsWrapToThreeRows() {
        // Same columnCount → 2 cols
        // 6 items / 2 cols = 3 rows → height = 3×50 + 2×8 = 166
        let size = measure(items: 6, itemSize: CGSize(width: 50, height: 50), containerWidth: 160)

        XCTAssertEqual(size.height, 166)
    }

    // MARK: - lineSpacing

    func test_sizeThatFits_lineSpacingAppliedBetweenRows() {
        // Same grid as fourItemsWrapToTwoRows but lineSpacing=20
        // height = 2×50 + 1×20 = 120
        let grid = FlexibleGrid(minimumSpacing: 8, lineSpacing: 20) {
            ForEach(0..<4, id: \.self) { _ in
                Color.red.frame(width: 50, height: 50)
            }
        }
        let size = measure(grid: grid, containerWidth: 160)

        XCTAssertEqual(size.height, 120)
    }

    func test_sizeThatFits_noLineSpacingWhenSingleRow() {
        // lineSpacing only applied between rows, not after the last row
        let grid = FlexibleGrid(minimumSpacing: 8, lineSpacing: 20) {
            ForEach(0..<2, id: \.self) { _ in
                Color.red.frame(width: 50, height: 50)
            }
        }
        let size = measure(grid: grid, containerWidth: 300)

        XCTAssertEqual(size.height, 50)
    }

    // MARK: - minimumSpacing

    func test_sizeThatFits_largerMinimumSpacingReducesColumnCount() {
        // minimumSpacing=20, maxWidth=118:
        //   2×50 + 1×20 = 120 > 118 → only 1 col fits
        // 4 items / 1 col = 4 rows → height = 4×50 + 3×8 = 224
        let grid = FlexibleGrid(minimumSpacing: 20, lineSpacing: 8) {
            ForEach(0..<4, id: \.self) { _ in
                Color.red.frame(width: 50, height: 50)
            }
        }
        let size = measure(grid: grid, containerWidth: 118)

        XCTAssertEqual(size.height, 224)
    }

    func test_sizeThatFits_itemsExactlyFitInRowWithNoRemainder() {
        // columnCount(itemWidth:50, minimumSpacing:8, maxWidth:108):
        //   2×50 + 1×8 = 108 ≤ 108 → count=2
        //   3×50 + 2×8 = 166 > 108  → stop → 2 cols
        // 6 items / 2 cols = 3 rows → height = 3×50 + 2×8 = 166
        let size = measure(items: 6, itemSize: CGSize(width: 50, height: 50), containerWidth: 108)

        XCTAssertEqual(size.height, 166)
    }

    // MARK: - Private helpers

    private func measure(items: Int, itemSize: CGSize, containerWidth: CGFloat) -> CGSize {
        let grid = FlexibleGrid(minimumSpacing: 8, lineSpacing: 8) {
            ForEach(0..<items, id: \.self) { _ in
                Color.red.frame(width: itemSize.width, height: itemSize.height)
            }
        }
        return measure(grid: grid, containerWidth: containerWidth)
    }

    private func measure<V: View>(grid: V, containerWidth: CGFloat) -> CGSize {
        let host = UIHostingController(rootView: grid)
        return host.sizeThatFits(in: CGSize(width: containerWidth, height: 10_000))
    }
}
