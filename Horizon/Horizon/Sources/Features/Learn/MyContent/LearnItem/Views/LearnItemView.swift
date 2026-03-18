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

import HorizonUI
import SwiftUI

struct LearnItemView: View {
    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false
    @State var viewModel: LearnItemViewModel

    var body: some View {
        VStack(spacing: .zero) {
            if viewModel.hasItems {
                contentView
            } else {
                emptyView
            }
        }
        .overlay { if viewModel.loaderIsVisible { loaderView } }
        .alert(isPresented: $viewModel.isErrorVisible) {
            Alert(title: Text(viewModel.errorMessage))
        }
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
    }

    private var emptyView: some View {
        ScrollView {
            Text("You don't have any items to show here.")
                .foregroundStyle(Color.huiColors.text.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .huiTypography(.p1)
                .padding(.huiSpaces.space24)
        }
        .refreshable { await viewModel.refresh() }
    }

    private var contentView: some View {
        VStack(spacing: .zero) {
            headerView
            if #available(iOS 18.0, *) {
                listItemsView
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in geometry.contentOffset.y
                    } action: { _, newOffset in
                        isShowHeader = newOffset <= 200
                        isShowDivider = newOffset >= 10
                    }
            } else {
                listItemsView
            }
        }
    }

    private var listItemsView: some View {
        List {
            ForEach(viewModel.filteredItems) { item in

                switch item.itemType {
                case .course:
                    LearnCourseCardView(model: item) {

                    } onTapLearningObject: { _, _ in

                    }
                    .plainListRowStyle()
                    .padding([.bottom, .horizontal], .huiSpaces.space24)
                case .program:
                    LearnProgramCardView(program: item)
                        .plainListRowStyle()
                        .padding([.bottom, .horizontal], .huiSpaces.space24)
                }
            }
            if viewModel.isSeeMoreVisible {
                seeMoreButton
                    .padding(.top, .huiSpaces.space16)
                    .plainListRowStyle()
            }
        }
        .listStyle(.plain)
        .dismissKeyboardOnTap()
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await viewModel.refresh() }
    }
    private var headerView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            HStack(spacing: .huiSpaces.space8) {
                searchView
               filterButton
            }
           .padding(.horizontal, .huiSpaces.space24)
           .padding(.top, .huiSpaces.space2)
            countOfVisibleItemsView
            Rectangle()
                .fill(Color.huiColors.primitives.grey14)
                .frame(height: 1.5)
                .hidden(!isShowDivider)
        }
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var searchView: some View {
        HorizonUI.Search(
            text: $viewModel.searchText,
            placeholder: String(localized: "Search"),
            size: .medium
        )
    }

    @ViewBuilder
    private var filterButton: some View {
//        let countBadge = viewModel.appliedFiltersCount
        HorizonUI.IconButton(Image.huiIcons.tune, type: .whiteGrayOutline) {
            viewModel.showFilter(viewController: viewController)
        }
//        .accessibilityFocused($focusedItemID, equals: filterButtonFocusedID)
        .accessibilityLabel(String(localized: "Filter and sort"))
//        .accessibilityValue(filterAccessibilityValue)
        .accessibilityHint(String(localized: "Double tap to open filter options"))
    }

    private var countOfVisibleItemsView: some View {
        Text(String(format: "%d items", viewModel.filteredItems.count))
            .foregroundStyle(Color.huiColors.text.dataPoint)
            .huiTypography(.p1)
            .padding(.horizontal, .huiSpaces.space24)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .accessibilityLabel(
                Text(
                    String(
                        format: String(localized: "Count of visible items is %d"),
                        viewModel.filteredItems.count
                    )
                )
            )
    }

    private var loaderView: some View {
        ZStack {
            Color.huiColors.surface.pagePrimary
                .padding(.top, .huiSpaces.space48)
            HorizonUI.Spinner(size: .small, showBackground: true)
        }
    }

    private var seeMoreButton: some View {
        SeeMoreButton(accessibilityHint: String(localized: "See more learning library")) {
            viewModel.seeMore()
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .plainListRowStyle()
    }
}
