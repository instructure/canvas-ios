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
    var currentPage: Binding<Int>?
    var totalPages: Binding<Int>?
    let cardContent: (Item) -> CardContent
    @State private var containerWidth: CGFloat = 0
    @State private var scrollPosition: Item.ID?
    private let cardSpacing: CGFloat = 8

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    cardContent(item)
                        .frame(width: cardContentWidth)
                        .padding(.leading, cardSpacing / 2)
                        .padding(.trailing, trailingPadding(for: index))
                }
            }
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
        .onWidthChange(update: $containerWidth)
        .onChange(of: scrollPosition) { _, _ in
            updateCurrentPage()
        }
        .onChange(of: items.count) { _, _ in
            updateTotalPages()
        }
        .onChange(of: containerWidth) { _, _ in
            updateTotalPages()
        }
        .onAppear {
            scrollPosition = items.first?.id
            updateTotalPages()
        }
    }

    private var columnCount: Int {
        LearnerDashboardWidgetLayoutHelpers.columns(for: containerWidth)
    }

    private var cardContentWidth: CGFloat {
        guard containerWidth > 0, columnCount > 0 else { return 0 }
        let slotWidth = containerWidth / CGFloat(columnCount)
        return slotWidth - cardSpacing
    }

    private var pageCount: Int {
        guard columnCount > 0 else { return 0 }
        return Int(ceil(Double(items.count) / Double(columnCount)))
    }

    private func trailingPadding(for index: Int) -> CGFloat {
        guard columnCount > 0 else { return 0 }

        let isLastItem = index == items.count - 1

        if isLastItem {
            let itemsInLastPage = items.count % columnCount
            let itemsInLastPageCount = itemsInLastPage == 0 ? columnCount : itemsInLastPage
            let missingItems = columnCount - itemsInLastPageCount

            if missingItems > 0 {
                let extraPaddingForMissingSlots = CGFloat(missingItems) * (containerWidth / CGFloat(columnCount))
                return (cardSpacing / 2) + extraPaddingForMissingSlots
            }
        }

        return cardSpacing / 2
    }

    private func updateCurrentPage() {
        guard let scrollPosition,
              let itemIndex = items.firstIndex(where: { $0.id == scrollPosition }),
              columnCount > 0 else { return }
        let page = itemIndex / columnCount
        currentPage?.wrappedValue = page
    }

    private func updateTotalPages() {
        totalPages?.wrappedValue = pageCount
    }
}

#if DEBUG

#Preview {
    @Previewable @State var currentPage1 = 0
    @Previewable @State var totalPages1 = 1
    @Previewable @State var currentPage3 = 0
    @Previewable @State var totalPages3 = 1
    @Previewable @State var currentPage5 = 0
    @Previewable @State var totalPages5 = 1

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

    return ScrollView {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Single Item")
                    .font(.headline)
                HorizontalCarouselView(
                    items: [items[0]],
                    currentPage: $currentPage1,
                    totalPages: $totalPages1
                ) { item in
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
                Text("Page \(currentPage1 + 1) of \(totalPages1)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Three Items (2 columns/page)")
                    .font(.headline)
                HorizontalCarouselView(
                    items: Array(items.prefix(3)),
                    currentPage: $currentPage3,
                    totalPages: $totalPages3
                ) { item in
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
                Text("Page \(currentPage3 + 1) of \(totalPages3)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Five Items")
                    .font(.headline)
                HorizontalCarouselView(
                    items: items,
                    currentPage: $currentPage5,
                    totalPages: $totalPages5
                ) { item in
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
                Text("Page \(currentPage5 + 1) of \(totalPages5)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
    }
}

#endif
