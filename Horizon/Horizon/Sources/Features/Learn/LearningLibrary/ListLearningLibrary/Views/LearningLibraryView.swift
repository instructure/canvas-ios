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

struct LearningLibraryView: View {
    // MARK: - VO Properties

    @State private var lastFocusedItemID: String?
    @AccessibilityFocusState private var focusedItemID: String?
    private let filterButtonFocusedID = "filterButtonFocusedID"

    // MARK: - Properties

    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false
    private let recommendationListView: LearningLibraryRecommendationListView

    // MARK: - Dependencies

    @State var viewModel: LearningLibraryViewModel

    // MARK: - Init

    init(viewModel: LearningLibraryViewModel, recommendationListView: LearningLibraryRecommendationListView) {
        _viewModel = State(initialValue: viewModel)
        self.recommendationListView = recommendationListView
    }

    var body: some View {
        learningLibraryView
        .background(Color.huiColors.surface.pagePrimary)
        .overlay { loaderView }
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
        .animation(.linear, value: [isShowHeader, isShowDivider])
        .animation(.easeInOut, value: viewModel.isGlobalSearchActive)
        .animation(.easeInOut, value: [viewModel.filteredSections.count, viewModel.globalSearchItems.count])
        .onFirstAppear { viewModel.fetchCollections() }
        .alert(isPresented: $viewModel.isErrorVisible) {
            Alert(title: Text(viewModel.errorMessage))
        }
        .onAppear {
            restoreFocusIfNeeded(after: 0.5)
        }
        .onReceive(viewModel.accessibilityMessagePublisher) { message in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
    }

    private var learningLibraryView: some View {
            VStack(alignment: .leading, spacing: .zero) {
                headerContainer
                if viewModel.isGlobalSearchActive {
                    globalSearchContentView
                } else {
                    libraryContentView
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.isGlobalSearchActive)
    }

    @ViewBuilder
    private var libraryContentView: some View {
        listLibraryView
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
                    isShowDivider = false
                }
            }
    }

    private var listLibraryView: some View {
        List {
            recommendationListView
                .plainListRowStyle()
            Section(header: Rectangle().fill(Color.clear).frame(height: 0)) {
                collectionView
            }
            .plainListRowStyle()

            ForEach(viewModel.filteredSections) { item in
                ListLearningLibraryView(
                    viewModel: viewModel,
                    section: item,
                    isExpendable: viewModel.filteredSections.count > 1,
                    lastFocusedItemID: $lastFocusedItemID
                )
                .id(item.id)
                // Add line
                Rectangle()
                    .fill(Color.huiColors.lineAndBorders.lineStroke)
                    .frame(height: 1)
                    .listRowBackground(Color.huiColors.surface.pagePrimary)
                    .plainListRowStyle()
            }
            .padding(.horizontal, .huiSpaces.space24)
            .listRowSpacing(.huiSpaces.space24)

            if viewModel.isSeeMoreVisible {
                seeMoreButton
                    .padding(.top, .huiSpaces.space16)
                    .plainListRowStyle()
            }
            extraPadding
                .plainListRowStyle()
        }
        .listSectionSpacing(.zero)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListHeaderHeight, 0)
        .listStyle(.grouped)
        .listRowSpacing(0)
        .listSectionSpacing(.compact)
        .listSectionSeparator(.hidden)
        .scrollIndicators(.hidden)
        .dismissKeyboardOnTap()
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            await viewModel.refresh()
            recommendationListView.reloadData()
        }
        .transition(.opacity.combined(with: .move(edge: .leading)))
    }

    @ViewBuilder
    private var globalSearchContentView: some View {
        globalSearchListView
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
                    isShowDivider = false
                }
            }
    }

    private var globalSearchListView: some View {
        List {
            if viewModel.globalSearchItems.isNotEmpty {
                countOfVisibleItemsView
                    .plainListRowStyle()
            }
            ForEach(viewModel.globalSearchItems) { item in
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
                .id(item.id)
                .accessibilityFocused($focusedItemID, equals: item.id)
                .padding(.top, .huiSpaces.space2)
            }
            .background(Color.huiColors.surface.pagePrimary)
            .padding(.horizontal, .huiSpaces.space24)

            if viewModel.globalSearchItems.isEmpty && !viewModel.isGlobalSearchLoading {
                Text("No results found. Try adjusting your search terms.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .background(Color.huiColors.surface.pagePrimary)
                    .padding(.horizontal, .huiSpaces.space24)
                    .plainListRowStyle()
            }

            extraPadding
        }
        .overlay { globalSearchLoaderView }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .scrollIndicators(.hidden)
    }

    private var extraPadding: some View {
        // Add extra padding at the bottom
        Rectangle()
            .fill(Color.clear)
            .frame(height: 10)
            .plainListRowStyle()
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.pagePrimary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }

    @ViewBuilder
    private var globalSearchLoaderView: some View {
        if viewModel.isGlobalSearchLoading {
            ZStack {
                Color.huiColors.surface.pagePrimary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }
    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            headerView
                .padding(.horizontal, .huiSpaces.space24)
                .padding(.top, .huiSpaces.space2)
            Rectangle()
                .fill(Color.huiColors.primitives.grey14)
                .frame(height: 1.5)
                .hidden(!isShowDivider)
        }
        .background(Color.huiColors.surface.pagePrimary)
        .hidden(viewModel.isLoaderVisible)
    }

    private var headerView: some View {
        HStack(spacing: .huiSpaces.space16) {
            searchView
            filterButton
        }
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
            viewModel.navigateToFilter(viewController: viewController)
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

    private var seeMoreButton: some View {
        SeeMoreButton(accessibilityHint: String(localized: "See more learning library")) {
            viewModel.seeMore()
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .plainListRowStyle()
    }

    private var emptyView: some View {
        Text("There is no any learning library yet.", bundle: .horizon)
            .padding(.horizontal, .huiSpaces.space24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.h3)
    }

    private var countOfVisibleItemsView: some View {
        Text(String(format: "%d items", viewModel.globalSearchItems.count))
            .foregroundStyle(Color.huiColors.text.dataPoint)
            .huiTypography(.p1)
            .padding(.horizontal, .huiSpaces.space24)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .hidden(viewModel.globalSearchItems.isEmpty || !viewModel.isGlobalSearchActive)
            .accessibilityLabel(
                Text(
                    String(
                        format: String(localized: "Count of visible items is %d"),
                        viewModel.globalSearchItems.count
                    )
                )
            )
    }

    private func restoreFocusIfNeeded(after: Double) {
        guard let lastFocusedItemID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedItemID = lastFocusedItemID
        }
    }

    private var collectionView: some View {
        HStack(spacing: .huiSpaces.space8) {
            Image.huiIcons.stacksFilled
                .foregroundStyle(Color.huiColors.primitives.grey45)
                .padding(.huiSpaces.space12)
                .background(Color.huiColors.primitives.grey12)
                .clipShape(.circle)
            Text("Collections")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.labelMediumBold)
        }
        .padding(.horizontal, .huiSpaces.space24)
    }

    private func setFocusToFirstResult() {
        guard let firstItem = viewModel.globalSearchItems.first else {
            return
        }
        lastFocusedItemID = firstItem.id
        restoreFocusIfNeeded(after: 1.8)
    }
}

#if DEBUG
#Preview {
    ListLearningLibraryAssembly.preview()
}
#endif
