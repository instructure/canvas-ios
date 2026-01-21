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

import Core
import SwiftUI

struct HorizontalCarouselView<Item: Identifiable, CardContent: View>: View {
    let items: [Item]
    let cardContent: (Item) -> CardContent
    @State private var scrolledID: Item.ID?

    private let horizontalPadding: CGFloat = 16
    private let cardSpacing: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let columnCount = LearnerDashboardWidgetLayoutHelpers.columns(for: geometry.size.width)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(items) { item in
                        cardContent(item)
                            .frame(width: cardWidth(containerWidth: geometry.size.width, columnCount: columnCount))
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, horizontalPadding)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledID)
            .scrollClipDisabled()
        }
    }

    private var currentIndex: Int {
        guard let scrolledID = scrolledID,
              let index = items.firstIndex(where: { $0.id == scrolledID }) else {
            return 0
        }
        return index
    }

    private func cardWidth(containerWidth: CGFloat, columnCount: Int) -> CGFloat {
        let totalHorizontalPadding = horizontalPadding * 2
        let totalSpacing = cardSpacing * CGFloat(columnCount - 1)
        let availableWidth = containerWidth - totalHorizontalPadding - totalSpacing
        return availableWidth / CGFloat(columnCount)
    }
}

#if DEBUG

#Preview {
    struct PreviewItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
    }

    let items = [
        PreviewItem(id: "1", title: "Item 1", subtitle: "Subtitle 1"),
        PreviewItem(id: "2", title: "Item 2", subtitle: "Subtitle 2"),
        PreviewItem(id: "3", title: "Item 3", subtitle: "Subtitle 3"),
        PreviewItem(id: "4", title: "Item 4", subtitle: "Subtitle 4"),
        PreviewItem(id: "5", title: "Item 5", subtitle: "Subtitle 5"),
        PreviewItem(id: "6", title: "Item 6", subtitle: "Subtitle 6")
    ]

    return HorizontalCarouselView(items: items) { item in
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.medium16, lineHeight: .fit)
                .foregroundColor(.textDarkest)
            Text(item.subtitle)
                .font(.regular14, lineHeight: .fit)
                .foregroundColor(.textDark)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .elevation(.cardLarge, background: .backgroundLightest)
    }
}

#endif
