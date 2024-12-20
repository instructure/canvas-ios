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

public struct JustifiedGrid<Content: View>: View {
    let itemCount: Int
    let content: (Int) -> Content
    let itemSize: CGSize
    let spacing: CGFloat
    let width: CGFloat

    public init(
        itemCount: Int,
        itemSize: CGSize,
        spacing: CGFloat = 0,
        width: CGFloat,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.itemCount = itemCount
        self.content = content
        self.itemSize = itemSize
        self.spacing = spacing
        self.width = width
    }

    struct Row {
        let id: String
        let itemIndexes: [Int]
        let placeholderCount: Int
    }

    var rows: [Row] {
        let columns = max(1, Int(floor((width + spacing) / (itemSize.width + spacing))))

        return stride(from: 0, to: itemCount, by: columns).map {
            let itemIndexes = stride(from: $0, to: min($0 + columns, itemCount), by: 1).map { $0 }
            return Row(
                id: "\(columns)-\($0)",
                itemIndexes: itemIndexes,
                placeholderCount: columns - itemIndexes.count
            )
        }
    }

    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(rows, id: \.id) { row in
                HStack(spacing: spacing) {
                    ForEach(row.itemIndexes, id: \.self) { itemIndex in
                        content(itemIndex)
                            .frame(width: itemSize.width, height: itemSize.height)
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(0..<row.placeholderCount, id: \.self) { _ in
                        Color.clear
                            .frame(width: itemSize.width, height: itemSize.height)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#if DEBUG
struct JustifiedGridPreviews: PreviewProvider {
    static var previews: some View {
        let values = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        GeometryReader { geometry in
            ScrollView {
                JustifiedGrid(itemCount: values.count, itemSize: CGSize(width: 50, height: 50), spacing: 8, width: geometry.size.width) { index in

                    Color.red.overlay(
                        Text(verbatim: "\(values[index])")
                    )
                }
            }
        }
    }
}
#endif
