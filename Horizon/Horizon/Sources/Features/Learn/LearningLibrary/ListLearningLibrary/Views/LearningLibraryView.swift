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
        .animation(.linear, value: isShowHeader)
        .onAppear { viewModel.fetchLearningLibrary() }
        .huiToast(
            viewModel: .init(text: viewModel.errorMessage, style: .error),
            isPresented: $viewModel.isErrorVisible
        )
    }

    private var learningLibraryView: some View {
        SingleAxisGeometryReader(initialSize: 300) { size in
            VStack(alignment: .leading, spacing: .zero) {
                headerContainer
                listLibraryView(width: size - 100)
            }
        }
    }
    private func listLibraryView(width: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .zero) {
                helperView
                contentView(width: width)
            }
            .padding(.horizontal, .huiSpaces.space24)
        }
        .refreshable { await viewModel.refresh() }
    }

    private func contentView(width: CGFloat) -> some View {
        VStack(spacing: .huiSpaces.space24) {
            listLearningLibraryView(width: width)
            if viewModel.filteredSections.isEmpty {
                Text("No results found. Try adjusting your search terms.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
            }

            if viewModel.isSeeMoreVisible {
                seeMoreButton
            }
        }
    }

    private func listLearningLibraryView(width: CGFloat) -> some View {
        ForEach(viewModel.filteredSections) { item in
            ListLearningLibraryView(
                section: item,
                viewModel: viewModel,
                availableWidth: width,
                isExpendable: viewModel.filteredSections.count > 1
            )
            Divider()
                .hidden(viewModel.filteredSections.last == item)
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
            bookmarkedButton
            completedButton
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
        }
        .huiElevation(level: .level2)
    }

    private var completedButton: some View {
        HorizonUI.IconButton(Image.huiIcons.history, type: .white) {
            viewModel.navigateToCompleted(viewController: viewController)
        }
        .huiElevation(level: .level2)
    }

    private var seeMoreButton: some View {
        SeeMoreButton(accessibilityHint: String(localized: "See more learning library")) {
            viewModel.seeMore()
        }
        .padding(.bottom, .huiSpaces.space16)
    }

    private var emptyView: some View {
        Text("There is no any learning library yet.", bundle: .horizon)
            .padding(.horizontal, .huiSpaces.space24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.h3)
    }
}

#if DEBUG
#Preview {
    ListLearningLibraryAssembly.preview()
}
#endif
