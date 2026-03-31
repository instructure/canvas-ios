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

import SwiftUI

/// A non-lazy grid layout that arranges subviews in rows and columns.
///
/// Unlike `LazyVGrid`, this layout renders all subviews eagerly.
///
/// Unlike `Grid`/`GridRow`, subviews are placed as a flat list, preserving their
/// SwiftUI identity across column count changes and enabling smooth animations
/// during layout transitions such as switching between 2- and 3-column layouts.
///
/// Each row's height equals the tallest subview in that row.
struct DashboardGridLayout: Layout {

    struct GridMetrics {
        let totalSize: CGSize
        let rowHeights: [CGFloat]
        let rowYOffsets: [CGFloat]
    }

    let columnCount: Int
    let itemWidth: CGFloat
    let spacing: CGFloat

    // MARK: - Layout Protocol Methods

    func makeCache(subviews: Subviews) -> GridMetrics {
        let itemProposal = ProposedViewSize(width: itemWidth, height: nil)
        let itemHeights = subviews.map { $0.sizeThatFits(itemProposal).height }
        return GridMetrics.make(itemHeights: itemHeights, columnCount: columnCount, itemWidth: itemWidth, spacing: spacing)
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout GridMetrics
    ) -> CGSize {
        cache.totalSize
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout GridMetrics
    ) {
        for (index, subview) in subviews.enumerated() {
            let row = index / columnCount
            let col = index % columnCount
            let origin = CGPoint(x: bounds.minX + CGFloat(col) * (itemWidth + spacing), y: bounds.minY + cache.rowYOffsets[row])
            subview.place(at: origin, proposal: ProposedViewSize(width: itemWidth, height: cache.rowHeights[row]))
        }
    }
}

extension DashboardGridLayout.GridMetrics {

    static func make(
        itemHeights: [CGFloat],
        columnCount: Int,
        itemWidth: CGFloat,
        spacing: CGFloat
    ) -> Self {
        let rowHeights = stride(from: 0, to: itemHeights.count, by: columnCount).map { rowStart in
            itemHeights[rowStart..<min(rowStart + columnCount, itemHeights.count)].max() ?? 0
        }
        let rowYOffsets = rowHeights.indices.map { row in
            rowHeights[0..<row].reduce(0, +) + CGFloat(row) * spacing
        }
        let totalHeight = rowHeights.reduce(0, +) + CGFloat(max(rowHeights.count - 1, 0)) * spacing
        let totalWidth = CGFloat(columnCount) * itemWidth + CGFloat(columnCount - 1) * spacing
        return Self(
            totalSize: CGSize(width: totalWidth, height: totalHeight),
            rowHeights: rowHeights,
            rowYOffsets: rowYOffsets
        )
    }
}
