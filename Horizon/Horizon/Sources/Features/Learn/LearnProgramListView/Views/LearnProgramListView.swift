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

struct LearnProgramListView: View {
    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false

    @State var viewModel: LearnProgramListViewModel

    var body: some View {
        VStack(spacing: .zero) {
            if viewModel.hasPrograms {
                headerView
                programListView
            } else {
               ScrollView {
                   emptyView
                }
               .refreshable { await viewModel.refresh() }
            }
        }
        .onFirstAppear { viewModel.fetchPrograms() }
        .overlay { loaderView }
        .animation(.smooth, value: viewModel.filteredPrograms.count)
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
        .background(Color.huiColors.surface.pagePrimary)
        .animation(.linear, value: isShowHeader)
    }

    private var programListView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .zero) {
                helperView
                contentView
            }
            .padding(.horizontal, .huiSpaces.space24)
        }
        .refreshable { await viewModel.refresh() }
    }

    private var contentView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            ForEach(viewModel.filteredPrograms) { program in
                Button {
                    viewModel.navigateToProgramDetails(
                        id: program.id,
                        viewController: viewController
                    )
                } label: {
                    LearnProgramCardView(program: program)
                }
            }

            if viewModel.isSeeMoreVisible {
                SeeMoreButton(accessibilityHint: String(localized: "Double tap to load more programs")) {
                    viewModel.seeMore()
                }
            }
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
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            if isShowHeader {
                searchView
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.top, .huiSpaces.space2)
            }
            filterView
                .padding(.horizontal, .huiSpaces.space24)
            Rectangle()
                .fill(Color.huiColors.primitives.grey14)
                .frame(height: 1.5)
                .hidden(!isShowDivider)
        }
        .background(Color.huiColors.surface.pagePrimary)
        .hidden(viewModel.isLoaderVisiable)
    }

    private var searchView: some View {
        HorizonUI.Search(
            text: $viewModel.searchText,
            placeholder: String(localized: "Search programs"),
            size: .large
        )
    }

    private var filterView: some View {
        HStack(spacing: .zero) {
            FilterView(
                items: ProgressStatus.programs,
                selectedOption: viewModel.selectedStatus) { option in
                    guard let option else { return }
                    viewModel.selectedStatus = option
                    viewModel.filter()
                }
            Spacer()
            Text(viewModel.filteredPrograms.count.description)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p1)
                .accessibilityLabel(
                    Text(
                        String(
                            format: String(localized: "Count of visible items is %@"),
                            viewModel.filteredPrograms.count.description
                        )
                    )
                )
        }
    }

    private var emptyView: some View {
        Text("You aren’t currently enrolled in a program.", bundle: .horizon)
            .padding(.huiSpaces.space24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(Color.huiColors.text.body)
            .huiTypography(.h3)
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisiable {
            ZStack {
                Color.huiColors.surface.pagePrimary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }
}
