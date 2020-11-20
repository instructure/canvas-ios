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

public struct JustifiedGrid<Item, Content: View>: View {
    let content: (Item) -> Content
    let id: KeyPath<Item, String>
    let items: [Item]
    let itemSize: CGSize
    let spacing: CGFloat
    let width: CGFloat

    public init(
        _ items: [Item],
        id: KeyPath<Item, String>,
        itemSize: CGSize,
        spacing: CGFloat = 0,
        width: CGFloat,
        @ViewBuilder content: @escaping (Item) -> Content
    ) {
        self.content = content
        self.id = id
        self.items = items
        self.itemSize = itemSize
        self.spacing = spacing
        self.width = width
    }

    struct Row {
        let id: String
        let items: [Item]
        let placeholders: [Int]
    }

    var rows: [Row] {
        let spacing: CGFloat = 8
        let columns = max(1, Int(floor((width + spacing) / (itemSize.width + spacing))))
        return stride(from: 0, to: items.count, by: columns).map {
            Row(
                id: "\(columns)-\($0)",
                items: Array(items[$0..<min($0 + columns, items.count)]),
                placeholders: Array(min(0, items.count - $0 - columns)..<0)
            )
        }
    }

    public var body: some View {
        VStack(spacing: spacing) {
            ForEach(rows, id: \.id) { row in
                HStack(spacing: spacing) {
                    ForEach(row.items, id: id) { item in
                        content(item)
                            .frame(width: itemSize.width, height: itemSize.height)
                            .frame(maxWidth: .infinity)
                    }
                    ForEach(row.placeholders, id: \.self) { _ in
                        Color.clear
                            .frame(width: itemSize.width, height: itemSize.height)
                    }
                }
            }
        }
    }
}
