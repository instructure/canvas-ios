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
    @State private var containerWidth: CGFloat = 0
    private let cardSpacing: CGFloat = 8

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: cardSpacing) {
                ForEach(items) { item in
                    cardContent(item)
                        .frame(width: cardWidth)
                        .id(item.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
        .scrollClipDisabled() // This is to let card shadows draw out of the scrollable area
        .onWidthChange(update: $containerWidth)
    }

    private var cardWidth: CGFloat {
        guard containerWidth > 0 else { return 0 }
        let columnCount = LearnerDashboardWidgetLayoutHelpers.columns(for: containerWidth)
        let totalSpacing = cardSpacing * CGFloat(columnCount - 1)
        let availableWidth = containerWidth - totalSpacing
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
        PreviewItem(id: "5", title: "Item 5", subtitle: "Subtitle 5")
    ]

    return VStack {
        HorizontalCarouselView(items: [items[0]]) { item in
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
        HorizontalCarouselView(items: items) { item in
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
    .padding(16)
}

#endif
