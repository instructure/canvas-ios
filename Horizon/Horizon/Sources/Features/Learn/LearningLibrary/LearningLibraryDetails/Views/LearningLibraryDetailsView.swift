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

struct ScrollData: Equatable {
    let offset: CGFloat
    let contentHeight: CGFloat
}

struct LearningLibraryDetailsView: View {
    // MARK: - VO Properties

    @State private var lastFocusedItemID: String?
    @AccessibilityFocusState private var focusedItemID: String?
    private let selectLOFilterFocusedID = "selectLOFilterFocusedID"
    private let selectTypeFilterFocusedID = "selectTypeFilterFocusedID"

    // MARK: - Properties

    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false

    // MARK: - Dependencies

    @State var viewModel: LearningLibraryDetailsViewModel

    // MARK: - Init

    init(viewModel: LearningLibraryDetailsViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if viewModel.hasItems {
                headerView
                contentView
            } else {
                ScrollView {
                    titleView
                    Text(viewModel.pageType.emptyStateTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .huiTypography(.p1)
                        .foregroundStyle(Color.huiColors.text.body)
                        .padding(.huiSpaces.space24)
                }
                .refreshable { await viewModel.refresh() }
            }
        }
        .toolbar(.hidden)
        .animation(.linear, value: isShowHeader)
        .background(Color.huiColors.surface.pagePrimary)
        .refreshable { await viewModel.refresh() }
        .dismissKeyboardOnTap()
        .scrollDismissesKeyboard(.immediately)
        .onFirstAppear { viewModel.fetchData() }
        .onAppear {
            ImageCacheConfiguration.configure()
        }
        .safeAreaInset(edge: .top, spacing: .zero) {
            if isShowHeader { navBarView }
        }
        .huiLoader(
            isVisible: viewModel.isLoaderVisible,
            topPadding: 44,
            backgroundColor: Color.huiColors.surface.pagePrimary
        )
        .huiToast(
            viewModel: .init(
                text: viewModel.errorMessage,
                style: .error
            ),
            isPresented: $viewModel.isErrorVisible
        )
    }

    private var navBarView: some View {
        HStack(spacing: .zero) {
            HorizonUI.IconButton(Image.huiIcons.arrowBack, type: .gray) {
                viewModel.pop(viewController: viewController)
            }
            Text("Back")
                .huiTypography(.buttonTextMedium)
                .foregroundColor(Color.huiColors.text.title)
            Spacer()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("Back"))
        .background(Color.huiColors.surface.pagePrimary)
        .padding(.horizontal, .huiSpaces.space16)
    }

    @ViewBuilder
    private var contentView: some View {
        if #available(iOS 18.0, *) {
            listLearningLibraryView
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
            listLearningLibraryView
        }
    }

    private var listLearningLibraryView: some View {
        List {
            ForEach(viewModel.filteredItems) { item in
                LearningLibraryCardView(
                    model: item,
                    isBookmarkLoading: viewModel.isBookmarkLoading(forItemWithId: item.id)
                ) {
                    lastFocusedItemID = item.id
                    viewModel.addBookmark(model: item)
                } enrollTap: {
                    lastFocusedItemID = item.id
                    viewModel.showEnrollConfirmation(model: item, viewController: viewController)
                } onTapItem: {
                    lastFocusedItemID = item.id
                    viewModel.navigateToLearningLibraryItem(item, from: viewController)
                }
                .id(item.id)
                .accessibilityFocused($focusedItemID, equals: item.id)
            }
            .padding(.top, .huiSpaces.space2)
            .padding(.horizontal, .huiSpaces.space24)

            if viewModel.filteredItems.isEmpty {
                Text("No results found. Try adjusting your search terms.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .padding(.horizontal, .huiSpaces.space24)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.huiColors.surface.pagePrimary)
            }

            if viewModel.isSeeMoreVisible {
                seeMoreButton
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.bottom, .huiSpaces.space16)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.huiColors.surface.pagePrimary)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .listRowSpacing(.huiSpaces.space24)
        .scrollIndicators(.hidden)
    }

    private var headerView: some View {
        VStack(spacing: .huiSpaces.space16) {
            if isShowHeader {
                titleView
                searchView
            }
            filterView

            Rectangle()
                .fill(Color.huiColors.primitives.grey14)
                .frame(height: 1.5)
                .hidden(!isShowDivider)
        }
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var titleView: some View {
        Text(viewModel.pageType.title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .huiTypography(.h3)
            .foregroundStyle(Color.huiColors.text.title)
            .padding(.horizontal, .huiSpaces.space24)
            .accessibilityAddTraits(.isHeader)
    }

    private var searchView: some View {
        HorizonUI.Search(
            text: $viewModel.searchText,
            placeholder: String(localized: "Search"),
            size: .medium
        )
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var filterView: some View {
        HStack(spacing: .huiSpaces.space8) {
            learningLibraryTypeFilterView
            learningObjectFilterView
            HorizonUI.IconButton(Image.huiIcons.close, type: .gray) {
                viewModel.clearAll()
            }
            .hidden(!viewModel.isClearButtonVisible)
            Spacer()
            countOfVisibleItemsView
                .hidden(viewModel.filteredItems.isEmpty)
        }
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var countOfVisibleItemsView: some View {
        Text("\(viewModel.filteredItems.count)")
            .foregroundStyle(Color.huiColors.text.dataPoint)
            .huiTypography(.p1)
            .accessibilityLabel(
                Text(
                    String(
                        format: String(localized: "Count of visible items is %@"),
                        viewModel.filteredItems.count.description
                    )
                )
            )
    }

    private var learningObjectFilterView: some View {
        FilterView(
            items: LearningLibraryObjectType.options,
            selectedOption: viewModel.selectedLearningObject) { option in
                guard let option else { return }
                lastFocusedItemID = selectLOFilterFocusedID
                viewModel.selectedLearningObject = option
                restoreFocusIfNeeded(after: 1.55)
            }
            .frame(width: 120)
            .id(selectLOFilterFocusedID)
            .accessibilityFocused($focusedItemID, equals: selectLOFilterFocusedID)
    }

    @ViewBuilder
    private var learningLibraryTypeFilterView: some View {
        let options: [OptionModel] = viewModel.pageType.isBookmarked
        ? LearningLibraryFilter.options(excluding: [.all, .completed])
        : LearningLibraryFilter.options(excluding: LearningLibraryFilter.allCases)
        FilterView(
            items: options,
            selectedOption: viewModel.selectedLearningLibrary) { option in
                guard let option else { return }
                lastFocusedItemID = selectTypeFilterFocusedID
                viewModel.selectedLearningLibrary = option
                restoreFocusIfNeeded(after: 1.55)
            }
            .frame(width: 120)
            .id(selectTypeFilterFocusedID)
            .accessibilityFocused($focusedItemID, equals: selectTypeFilterFocusedID)
    }

    private var seeMoreButton: some View {
        SeeMoreButton(accessibilityHint: String(localized: "Double tap to load more items")) {
            viewModel.seeMore()
        }
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
    LearningLibraryAssembly.preview()
}
#endif
