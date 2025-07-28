//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public struct FlowLayout: Layout {

    let spacing: CGFloat
    let minimumLineSpacing: CGFloat

    public init(spacing: CGFloat, minimumLineSpacing: CGFloat) {
        self.spacing = spacing
        self.minimumLineSpacing = minimumLineSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {

        cache.placements.removeAll()

        let proposed = proposal.replacingUnspecifiedDimensions()

        var cursor: CGPoint = .zero
        var totalSize: CGSize = .zero

        var rowHeight: CGFloat = 0
        for subview in subviews {
            let subSize = subview.sizeThatFits(proposal)

            if totalSize == .zero {
                cache.placements.append(cursor)

                cursor.x = subSize.width
                rowHeight = subSize.height
                totalSize = subSize
                continue
            }

            let nextCursorX = cursor.x + spacing + subSize.width

            if nextCursorX <= proposed.width {
                rowHeight = max(rowHeight, subSize.height)

                totalSize.height = max(totalSize.height, cursor.y + rowHeight)
                totalSize.width = max(totalSize.width, nextCursorX)

                cache.placements.append(
                    CGPoint(x: cursor.x + spacing, y: cursor.y)
                )

                cursor.x = nextCursorX

            } else {

                cursor.y += rowHeight + minimumLineSpacing

                cache.placements.append(CGPoint(x: 0, y: cursor.y))

                cursor.x = subSize.width
                rowHeight = subSize.height
                totalSize.height = max(totalSize.height, cursor.y + rowHeight)
            }
        }

        return totalSize
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        subviews.indices.forEach { index in
            let cursor = cache.placements[index]
            let point = CGPoint(
                x: bounds.minX + cursor.x,
                y: bounds.minY + cursor.y
            )
            subviews[index].place(at: point, proposal: proposal)
        }
    }

    public func makeCache(subviews: Subviews) -> Cache { Cache() }

    public struct Cache: Hashable {
        var placements: [CGPoint] = []
    }
}

#if DEBUG

struct Val: Identifiable {
    let id: Int, value: Int, fontSize: CGFloat
}

#Preview {

    let list = Array(1 ... 200)
        .map({ Val(
            id: $0,
            value: Int.random(in: 1 ... 10000),
            fontSize: CGFloat.random(in: 10 ... 30)
            )
        })

    ScrollView {

        VStack(spacing: 0) {
            Rectangle().fill(Color.red).frame(height: 50)
            FlowLayout(spacing: 5, minimumLineSpacing: 10) {

                ForEach(list) { val in

                    Button {
                        print(val.value)
                    } label: {
                        Text("\(val.value)")
                            .font(.system(size: val.fontSize))
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
            }
            .padding(10)
        }
    }
    .environment(\.layoutDirection, .rightToLeft)
}

#endif
