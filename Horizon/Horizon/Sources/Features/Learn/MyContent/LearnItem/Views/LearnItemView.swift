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
    // MARK: - VO Properties

    @State private var lastFocusedItemID: String?
    @AccessibilityFocusState private var focusedItemID: String?
    private let filterButtonFocusedID = "filterButtonFocusedID"

    // MARK: - Properties

    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false
    @State var viewModel: LearnItemViewModel

    var body: some View {
        VStack(spacing: .zero) {
            if viewModel.hasItems {
                headerView
            }
            if !viewModel.isLoaderVisible {
                if viewModel.filteredItems.isNotEmpty {
                    contentView
                } else {
                    emptyView
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay { if viewModel.isLoaderVisible { loaderView } }
        .alert(isPresented: $viewModel.isErrorVisible) {
            Alert(title: Text(viewModel.errorMessage))
        }
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
        .onAppear {
            restoreFocusIfNeeded(after: 0.5)
        }
        .onReceive(viewModel.accessibilityMessagePublisher) { message in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isShowHeader = true
                isShowDivider = false
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
    }

    private var emptyView: some View {
        ScrollView {
            Text(viewModel.hasActiveFilters
                 ? String(localized: "No results found. Try adjusting your search terms.")
                 : String(localized: "You aren’t currently enrolled in a course")
            )
            .foregroundStyle(Color.huiColors.text.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.p1)
            .padding(.horizontal, .huiSpaces.space24)
        }
        .refreshable { await viewModel.refresh() }
    }

    private var contentView: some View {
        VStack(spacing: .zero) {
            if #available(iOS 18.0, *) {
                listItemsView
                    .onScrollGeometryChange(for: ScrollData.self) { geometry in
                        ScrollData(
                            offset: geometry.contentOffset.y,
                            contentHeight: geometry.contentSize.height
                        )
                    } action: { _, newValue in
                        let viewportHeight = UIScreen.main.bounds.height

                        if newValue.contentHeight > viewportHeight + 200 {
                            isShowHeader = newValue.offset <= 200
                            isShowDivider = newValue.offset >= 10
                        } else {
                            isShowHeader = true
                            isShowDivider = newValue.offset >= 10
                        }
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
                        lastFocusedItemID = item.id
                        viewModel.navigateToCourseDetails(id: item.id, enrollmentID: item.enrollmentId, programName: nil, viewController: viewController)
                    } onTapLearningObject: {
                        lastFocusedItemID = item.id
                        viewModel.navigateToItemSequence(courseID: item.id, moduleItemID: item.nextModuleItemID, viewController: viewController)
                    }
                    .id(item.id)
                    .accessibilityFocused($focusedItemID, equals: item.id)
                    .plainListRowStyle()
                    .padding([.bottom, .horizontal], .huiSpaces.space24)
                case .program:
                    Button {
                        lastFocusedItemID = item.id
                        viewModel.navigateToProgramDetails(id: item.id, viewController: viewController)
                    } label: {
                        LearnProgramCardView(program: item)
                            .plainListRowStyle()
                            .padding([.bottom, .horizontal], .huiSpaces.space24)
                    }
                    .id(item.id)
                    .accessibilityFocused($focusedItemID, equals: item.id)
                    .accessibilityLabel(item.accessibilityLearnDescription)
                    .plainListRowStyle()
                    .buttonStyle(.plain)
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
        .submitLabel(.return)
        .onSubmit {
            setFocusToFirstResult()
        }
    }

    @ViewBuilder
    private var filterButton: some View {
        let countBadge = viewModel.appliedFiltersCount
        HorizonUI.IconButton(Image.huiIcons.tune, type: .whiteGrayOutline, badgeType: countBadge > 0 ? .number(countBadge.description) : nil) {
            viewModel.showFilter(viewController: viewController)
            lastFocusedItemID = filterButtonFocusedID
        }
        .accessibilityFocused($focusedItemID, equals: filterButtonFocusedID)
        .accessibilityLabel(String(localized: "Filter and sort"))
        .accessibilityValue(filterAccessibilityValue)
        .accessibilityHint(String(localized: "Double tap to open filter options"))
    }

    private var filterAccessibilityValue: String {
        if viewModel.appliedFiltersCount == 0 {
            return String(localized: "No filters applied")
        } else if viewModel.appliedFiltersCount == 1 {
            return String(localized: "1 filter applied")
        } else {
            return String(format: String(localized: "%d filters applied"), viewModel.appliedFiltersCount)
        }
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

    private func restoreFocusIfNeeded(after: Double) {
        guard let lastFocusedItemID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedItemID = lastFocusedItemID
        }
    }

    private func setFocusToFirstResult() {
        guard let firstItem = viewModel.filteredItems.first else {
            return
        }
        lastFocusedItemID = firstItem.id
        restoreFocusIfNeeded(after: 1.8)
    }
}
