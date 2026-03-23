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

/// FlexibleGrid places as many subviews in a row as possible. The remaining space is distributed evenly between the row's subviews.
/// If the last row is not complete the subviews are placed from the leading edge.
public struct FlexibleGrid: Layout {
    let minimumSpacing: CGFloat
    let lineSpacing: CGFloat

    public init(minimumSpacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        self.minimumSpacing = minimumSpacing
        self.lineSpacing = lineSpacing
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        guard !subviews.isEmpty, let maxWidth = proposal.width else { return .zero }

        let itemWidth = measureItemWidth(subviews: subviews, maxWidth: maxWidth)
        let columns = columnCount(itemWidth: itemWidth, maxWidth: maxWidth)
        let rowCount = (subviews.count + columns - 1) / columns
        let rowHeight = measureRowHeight(subviews: subviews, maxWidth: maxWidth)

        let totalHeight = CGFloat(rowCount) * rowHeight + CGFloat(max(rowCount - 1, 0)) * lineSpacing

        let contentWidth = {
            if let proposedWidth = proposal.width {
                return proposedWidth
            } else {
                let gaps = max(columns - 1, 0)
                return CGFloat(columns) * itemWidth + CGFloat(gaps) * minimumSpacing
            }
        }()

        return CGSize(width: contentWidth, height: totalHeight)
    }

    public func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard !subviews.isEmpty else { return }

        let itemWidth = measureItemWidth(subviews: subviews, maxWidth: bounds.width)
        let columns = columnCount(itemWidth: itemWidth, maxWidth: bounds.width)
        let rowHeight = measureRowHeight(subviews: subviews, maxWidth: bounds.width)

        let totalItemWidth = CGFloat(columns) * itemWidth
        let gaps = max(columns - 1, 0)
        let uniformSpacing = gaps > 0 ? (bounds.width - totalItemWidth) / CGFloat(gaps) : 0

        for (index, subview) in subviews.enumerated() {
            let col = index % columns
            let row = index / columns

            let x = bounds.minX + CGFloat(col) * (itemWidth + uniformSpacing)

            let y = bounds.minY + CGFloat(row) * (rowHeight + lineSpacing)
            let size = subview.sizeThatFits(ProposedViewSize(width: itemWidth, height: nil))
            let yOffset = (rowHeight - size.height) / 2

            subview.place(
                at: CGPoint(x: x, y: y + yOffset),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )
        }
    }

    private func measureItemWidth(subviews: Subviews, maxWidth: CGFloat) -> CGFloat {
        subviews.reduce(CGFloat(0)) { maxSoFar, subview in
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            return max(maxSoFar, size.width)
        }
    }

    private func measureRowHeight(subviews: Subviews, maxWidth: CGFloat) -> CGFloat {
        subviews.reduce(CGFloat(0)) { maxSoFar, subview in
            let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            return max(maxSoFar, size.height)
        }
    }

    private func columnCount(itemWidth: CGFloat, maxWidth: CGFloat) -> Int {
        guard itemWidth > 0 else { return 1 }
        var count = 1
        while CGFloat(count + 1) * itemWidth + CGFloat(count) * minimumSpacing <= maxWidth {
            count += 1
        }
        return count
    }
}

#Preview("Left to Right") {
    let colors: [Color] = [.red, .blue, .green, .yellow, .indigo, .teal, .purple]

    FlexibleGrid {
        ForEach(colors, id: \.self) { color in
            Circle()
                .fill(color)
                .scaledFrame(size: 40)
        }
    }
}

#Preview("Right to Left") {
    let colors: [Color] = [.red, .blue, .green, .yellow, .indigo, .teal, .purple]

    FlexibleGrid {
        ForEach(colors, id: \.self) { color in
            Circle()
                .fill(color)
                .scaledFrame(size: 40)
        }
    }
    .environment(\.layoutDirection, .rightToLeft)
}
