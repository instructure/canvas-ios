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

import Core
import HorizonUI
import SwiftUI

struct ListLearningLibraryView: View {
    // MARK: - VO Properties

    @AccessibilityFocusState private var focusedItemID: String?
    private var expandButtonFocusedID: String { "expandButton_\(section.id)" }

    // MARK: - Private variables

    @State private var isExpanded: Bool = true
    @Environment(\.viewController) private var viewController

    // MARK: - Dependencies

    @State var viewModel: LearningLibraryViewModel
    let section: LearningLibrarySectionModel
    let isExpendable: Bool
    @Binding var lastFocusedItemID: String?

    var body: some View {
        Section(header: headerView) {
            if isExpanded {
                if section.items.isNotEmpty {
                    items

                    if section.hasMoreItems {
                        viewAllCollectionsButton
                    }
                } else {
                    Text("No items in this collection")
                        .foregroundStyle(Color.huiColors.text.title)
                        .huiTypography(.buttonTextLarge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowSeparatorTint(Color.huiColors.surface.pagePrimary)
                        .listRowBackground(Color.huiColors.surface.pagePrimary)
                }
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listSectionSeparatorTint(Color.huiColors.surface.pagePrimary)
    }

    private var headerView: some View {
        HStack(alignment: .top) {
            Text(section.name)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.h3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .accessibilityHidden(isExpendable)

            Spacer()

            if isExpendable {
                HorizonUI.IconButton(
                    Image.huiIcons.keyboardArrowDown,
                    type: .darkOutline,
                    isSmall: true
                ) {
                    withAnimation(.smooth(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(Text(section.name))
                .accessibilityValue(Text(isExpanded ? String(localized: "Expanded") : String(localized: "Collapsed")))
                .accessibilityHint(Text(isExpanded ? String(localized: "Double tap to collapse section") : String(localized: "Double tap to expand section")))
            }
        }
        .padding(.vertical, .huiSpaces.space16)
    }

    private var items: some View {
        ForEach(section.sortedItems) { item in
            LearningLibraryCardView(
                model: item,
                isBookmarkLoading: viewModel.isBookmarkLoading(forItemWithId: item.id),
                onBookmarkTap: {
                    lastFocusedItemID = item.id
                    viewModel.addBookmark(model: item)
                }, enrollTap: {
                    lastFocusedItemID = item.id
                    viewModel.showEnrollConfirmation(model: item, viewController: viewController)
                }, onTapItem: {
                    lastFocusedItemID = item.id
                    viewModel.navigateToLearningLibraryItemDetails(item, from: viewController)
                }
            )
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowSeparatorTint(Color.huiColors.surface.pagePrimary)
            .id(item.id)
            .accessibilityFocused($focusedItemID, equals: item.id)
        }
    }

    private var viewAllCollectionsButton: some View {
        HStack {
            Text(String(format: String(localized: "%@ items"), section.totalItemCount))
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
            HorizonUI.PrimaryButton(String(localized: "View full collection"),
                                    type: .white,
                                    fillsWidth: false,
                                    trailing: Image.huiIcons.arrowForward
            ) {
                viewModel.navigateToDetails(section: section, viewController: viewController)
            }
            .huiElevation(level: .level2)
            .fixedSize(horizontal: true, vertical: false)
        }
        .listRowBackground(Color.huiColors.surface.pagePrimary)
    }

    private func restoreFocusIfNeeded() {
        guard let lastFocusedItemID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            focusedItemID = lastFocusedItemID
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var lastFocusedItemID: String?

        var body: some View {
            ListLearningLibraryView(
                viewModel: LearningLibraryViewModel(router: AppEnvironment.shared.router),
                section: LearningLibrarySectionModel(
                    id: "1",
                    name: "Learning Library Name",
                    hasMoreItems: true,
                    totalItemCount: "10",
                    items: [
                        .init(
                            id: "ID-1",
                            name: "Adipiscing Elit Learning Object Name Here",
                            imageURL: nil,
                            itemType: .assessment,
                            estimatedTime: "10 mins",
                            isRecommended: true,
                            isCompleted: true,
                            isBookmarked: true,
                            numberOfUnits: 10
                        )
                    ]
                ),
                isExpendable: true,
                lastFocusedItemID: $lastFocusedItemID
            )
            .padding()
            .background(Color.huiColors.surface.cardSecondary)
        }
    }

    return PreviewWrapper()
}
