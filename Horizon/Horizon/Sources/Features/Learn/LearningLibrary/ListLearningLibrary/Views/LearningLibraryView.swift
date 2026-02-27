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
    private let selectLOFilterFocusedID = "selectLOFilterFocusedID"
    private let selectTypeFilterFocusedID = "selectTypeFilterFocusedID"
    private let bookMarkButtonFocusedID = "bookMarkButtonFocusedID"

    // MARK: - Properties

    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false

    // MARK: - Dependencies

    @State var viewModel: LearningLibraryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if viewModel.hasLibrary {
                learningLibraryView
            } else {
                ScrollView {
                    emptyView
                }
                .refreshable { await viewModel.refresh() }
            }
        }
        .background(Color.huiColors.surface.pagePrimary)
        .overlay { loaderView }
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
        .animation(.linear, value: [isShowHeader, isShowDivider])
        .animation(.easeInOut(duration: 0.3), value: viewModel.isGlobalSearchActive)
        .onFirstAppear { viewModel.fetchCollections() }
        .alert(isPresented: $viewModel.isErrorVisible) {
            Alert(title: Text(viewModel.errorMessage))
        }
        .onAppear {
            restoreFocusIfNeeded(after: 0.5)
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
        if #available(iOS 18.0, *) {
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
        } else {
            listLibraryView
        }
    }

    private var listLibraryView: some View {
        List {
            ForEach(viewModel.filteredSections) { item in
                ListLearningLibraryView(
                    viewModel: viewModel,
                    section: item,
                    isExpendable: viewModel.filteredSections.count > 1,
                    lastFocusedItemID: $lastFocusedItemID
                )
                .id(item.id)
                .listRowBackground(Color.huiColors.surface.pagePrimary)
            }
            .padding(.horizontal, .huiSpaces.space24)

            if viewModel.isSeeMoreVisible {
                seeMoreButton
                    .padding(.top, .huiSpaces.space16)
            }
        }
        .listSectionSpacing(.zero)
        .scrollContentBackground(.hidden)
        .environment(\.defaultMinListHeaderHeight, 0)
        .listStyle(.grouped)
        .listRowSpacing(.huiSpaces.space24)
        .listSectionSpacing(.compact)
        .listSectionSeparator(.hidden)
        .scrollIndicators(.hidden)
        .dismissKeyboardOnTap()
        .scrollDismissesKeyboard(.immediately)
        .refreshable { await viewModel.refresh() }
        .transition(.opacity.combined(with: .move(edge: .leading)))
    }

    @ViewBuilder
    private var globalSearchContentView: some View {
        if #available(iOS 18.0, *) {
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
        } else {
            globalSearchListView
        }
    }

    private var globalSearchListView: some View {
        List {
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
                        viewModel.navigateToLearningLibraryItem(item, from: viewController)
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
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.huiColors.surface.pagePrimary)
            }
        }
        .overlay { globalSearchLoaderView }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .listRowSpacing(.huiSpaces.space24)
        .scrollIndicators(.hidden)
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
            if !isShowDivider {
                filterView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
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
            bookmarkedButton
        }
    }

    private var searchView: some View {
        HorizonUI.Search(
            text: $viewModel.searchText,
            placeholder: String(localized: "Search"),
            size: .medium
        )
    }

    private var bookmarkedButton: some View {
        HorizonUI.IconButton(Image.huiIcons.bookmarks, type: .white) {
            viewModel.navigateToBookmarks(viewController: viewController)
            lastFocusedItemID = bookMarkButtonFocusedID
        }
        .huiElevation(level: .level2)
        .accessibilityFocused($focusedItemID, equals: bookMarkButtonFocusedID)
    }

    private var seeMoreButton: some View {
        SeeMoreButton(accessibilityHint: String(localized: "See more learning library")) {
            viewModel.seeMore()
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(Color.huiColors.surface.pagePrimary)
    }

    private var emptyView: some View {
        Text("There is no any learning library yet.", bundle: .horizon)
            .padding(.horizontal, .huiSpaces.space24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.h3)
    }

    private var filterView: some View {
        HStack(spacing: .huiSpaces.space8) {
            learningLibraryTypeFilterView
            learningObjectFilterView
            HorizonUI.IconButton(Image.huiIcons.close, type: .gray) {
                viewModel.clearAll()
            }
            .hidden(!viewModel.isGlobalSearchActive)
            Spacer()
            countOfVisibleItemsView
        }
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var learningObjectFilterView: some View {
        FilterView(
            items: LearningLibraryObjectType.options,
            selectedOption: viewModel.selectedLearningObject
        ) { option in
            guard let option else { return }
            lastFocusedItemID = selectLOFilterFocusedID
            viewModel.selectedLearningObject = option
            restoreFocusIfNeeded(after: 1.6)
        }
        .id(selectLOFilterFocusedID)
        .accessibilityFocused($focusedItemID, equals: selectLOFilterFocusedID)
    }

    private var learningLibraryTypeFilterView: some View {
        FilterView(
            items: LearningLibraryFilter.options(excluding: LearningLibraryFilter.allCases),
            selectedOption: viewModel.selectedLearningLibrary
        ) { option in
            guard let option else { return }
            lastFocusedItemID = selectTypeFilterFocusedID
            viewModel.selectedLearningLibrary = option
            restoreFocusIfNeeded(after: 1.6)
        }
        .id(selectTypeFilterFocusedID)
        .accessibilityFocused($focusedItemID, equals: selectTypeFilterFocusedID)
    }

    private var countOfVisibleItemsView: some View {
        Text("\(viewModel.globalSearchItems.count)")
            .foregroundStyle(Color.huiColors.text.dataPoint)
            .huiTypography(.p1)
            .hidden(viewModel.globalSearchItems.isEmpty || !viewModel.isGlobalSearchActive)
    }

    private func restoreFocusIfNeeded(after: Double) {
        guard let lastFocusedItemID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedItemID = lastFocusedItemID
        }
    }
}

#if DEBUG
#Preview {
    ListLearningLibraryAssembly.preview()
}
#endif
