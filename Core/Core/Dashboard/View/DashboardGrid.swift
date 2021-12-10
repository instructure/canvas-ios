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

public struct DashboardGrid<Content: View>: View {
    private struct Row {
        let id: String
        let itemIndexes: [Int]
    }

    private let itemCount: Int
    private let itemWidth: CGFloat
    private let spacing: CGFloat
    private let columnCount: Int
    private let content: (Int) -> Content

    private var rows: [Row] {
        stride(from: 0, to: itemCount, by: columnCount).map {
            let itemIndexes = stride(from: $0, to: min($0 + columnCount, itemCount), by: 1).map { $0 }
            return Row(id: "\($0 / columnCount)", itemIndexes: itemIndexes)
        }
    }

    public init(itemCount: Int, itemWidth: CGFloat, spacing: CGFloat, columnCount: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self.itemCount = itemCount
        self.itemWidth = itemWidth
        self.spacing = spacing
        self.columnCount = columnCount
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(rows, id: \.id) { row in
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(row.itemIndexes, id: \.self) { itemIndex in
                        content(itemIndex)
                            .frame(width: itemWidth)
                    }
                }
                .fixedSize(horizontal: true, vertical: true)
            }
        }
    }
}

struct DashboardGridPreviews: PreviewProvider {
    static var previews: some View {
        let labels = [
            "1", "2222 2 222222 222222 22 2 2 2222 22 2222 222 22222",
            "3333 3 333 33 3333333 3333", "4",
            "5",
        ]
        GeometryReader { geometry in
            let spacing: CGFloat = 8
            let columnCount: CGFloat = 2
            let columnWidth = (geometry.size.width - (((columnCount - 1) * spacing)))  / columnCount
            DashboardGrid(itemCount: labels.count, itemWidth: columnWidth, spacing: spacing, columnCount: Int(columnCount)) { index in
                Text(labels[index])
                    .frame(width: columnWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.black, width: 1)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
