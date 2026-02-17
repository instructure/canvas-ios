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

struct LearningLibraryDetailsView: View {
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
                SingleAxisGeometryReader(initialSize: 300) { size in
                    listLearningLibraryView(width: size - 32)
                }
            } else {
                ScrollView {
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
        .animation(.easeOut, value: viewModel.filteredItems)
        .onFirstAppear { viewModel.fetchLearningLibraryItems() }
        .safeAreaInset(edge: .top, spacing: .zero) {
            if isShowHeader { navBarView }
        }
        .huiLoader(
            isVisible: viewModel.isLoaderVisible,
            topPadding: 44,
            backgroundColor: Color.huiColors.surface.pagePrimary
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
        .background(Color.huiColors.surface.pagePrimary)
        .padding(.horizontal, .huiSpaces.space16)
    }

    private func listLearningLibraryView(width: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .zero) {
                helperView
                VStack(spacing: .huiSpaces.space24) {
                    ForEach(viewModel.filteredItems) { item in
                        LearningLibraryCardView(
                            model: item,
                            width: width,
                            isBookmarkLoading: viewModel.isBookmarkLoading(forItemWithId: item.id),
                            isEnrollLoading: viewModel.isEnrollLoading(forItemWithId: item.id),
                        ) {
                            viewModel.addBookmark(model: item)
                        } enrollTap: {
                            viewModel.enroll(model: item)
                        } onTapItem: {
                            viewModel.navigateToDetails(model: item, viewController: viewController)
                        }
                    }
                }
                .padding(.top, .huiSpaces.space2)
                if viewModel.filteredItems.isEmpty {
                    Text("No results found. Try adjusting your search terms.")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .huiTypography(.p1)
                        .foregroundStyle(Color.huiColors.text.body)
                }

                if viewModel.isSeeMoreVisible {
                    seeMoreButton
                }
            }
            .padding(.horizontal, .huiSpaces.space24)
            .padding(.bottom, .huiSpaces.space16)
        }
    }

    private var helperView: some View {
        Color.clear
            .frame(height: 1)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
                isShowDivider = frame.minY < 100
            }
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
            switch viewModel.pageType {
            case .details:
                learningObjectFilterView
                learningLibraryTypeFilterView
            case .completed, .bookmarks:
                learningObjectFilterView
            }

            Spacer()
            countOfVisiableItemsView
        }
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var countOfVisiableItemsView: some View {
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
                viewModel.selectedLearningObject = option
            }
    }

    private var learningLibraryTypeFilterView: some View {
        FilterView(
            items: LearningLibraryFilter.options,
            selectedOption: viewModel.selectedLearningLibrary) { option in
                guard let option else { return }
                viewModel.selectedLearningLibrary = option
            }
    }

    private var seeMoreButton: some View {
        SeeMoreButton(accessibilityHint: String(localized: "Double tap to load more items")) {
            viewModel.seeMore()
        }
        .padding(.top, .huiSpaces.space24)
    }
}

#if DEBUG
#Preview {
    LearningLibraryAssembly.preview()
}
#endif
