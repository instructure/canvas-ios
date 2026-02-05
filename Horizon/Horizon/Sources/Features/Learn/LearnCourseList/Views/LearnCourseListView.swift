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

struct LearnCourseListView: View {
    // MARK: - VO

    @State private var lastFocusedCourseID: String?
    @AccessibilityFocusState private var focusedCourseID: String?
    private let selectFilterFocusedID = "selectFilterFocusedID"

    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false
    @State var viewModel: LearnCourseListViewModel

    var body: some View {
        VStack(spacing: .zero) {
            if viewModel.hasCourses {
                headerView

                SingleAxisGeometryReader(initialSize: 300) { size in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: .zero) {
                            helperView
                            contentView(width: size - 48)
                        }
                        .padding(.horizontal, .huiSpaces.space24)
                    }
                    .refreshable { await viewModel.refresh() }
                }
            } else {
                emptyView
            }
        }
        .overlay { loaderView }
        .onFirstAppear { viewModel.getCourses() }
        .animation(.smooth, value: viewModel.filteredCourses.count)
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
        .background(Color.huiColors.surface.pagePrimary)
        .animation(.linear, value: isShowHeader)
        .onAppear { restoreFocusIfNeeded(after: 0.1) }
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
    }

    private func contentView(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            listCourseView(width: width)
            if viewModel.filteredCourses.isEmpty {
                CourseListEmptyView()
            }

            if viewModel.isSeeMoreVisible {
                seeMoreButton
            }
        }
    }

    private var searchView: some View {
        HorizonUI.Search(
            text: $viewModel.searchText,
            placeholder: String(localized: "Search courses"),
            size: .medium
        )
    }

    private var filterView: some View {
        HStack(spacing: .zero) {
            FilterView(
                items: ProgressStatus.courses,
                selectedOption: viewModel.selectedStatus) { option in
                    guard let option else { return }
                    lastFocusedCourseID = selectFilterFocusedID
                    viewModel.selectedStatus = option
                    viewModel.filter()
                    restoreFocusIfNeeded(after: 1)
                }
                .id(selectFilterFocusedID)
                .accessibilityFocused($focusedCourseID, equals: selectFilterFocusedID)
            Spacer()
            Text(viewModel.filteredCourses.count.description)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p1)
                .accessibilityLabel(
                    Text(
                        String(
                            format: String(localized: "Count of visible items is %@"),
                            viewModel.filteredCourses.count.description
                        )
                    )
                )
        }
    }

    private func listCourseView(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            ForEach(viewModel.filteredCourses) { course in
                LearnCourseCardView(model: course, width: width) {
                    lastFocusedCourseID = course.id
                    viewModel.navigateToCourseDetails(
                        id: course.id,
                        enrollmentID: course.enrollmentID,
                        programName: course.programs.first?.name,
                        viewController: viewController
                    )
                } onTapLearningObject: { _, url in
                    if let url = url,
                       let currentLearningObject = course.currentLearningObject {
                        lastFocusedCourseID = course.id
                        viewModel.navigateToItemSequence(
                            url: url,
                            learningObject: currentLearningObject,
                            viewController: viewController
                        )
                    }
                }
                .id(course.id)
                .accessibilityFocused($focusedCourseID, equals: course.id)
            }
        }
    }

    private var seeMoreButton: some View {
        SeeMoreButton(accessibilityHint: String(localized: "Double tap to load more courses")) {
            viewModel.seeMore()
        }
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

    private var emptyView: some View {
        ScrollView {
            Text("You aren’t currently enrolled in a course.", bundle: .horizon)
                .padding(.huiSpaces.space24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .foregroundStyle(Color.huiColors.text.body)
                .huiTypography(.h3)
                .padding(.top, .huiSpaces.space32)
        }
        .refreshable { await viewModel.refresh() }
    }

    private func restoreFocusIfNeeded(after: Double) {
        guard let lastFocused = lastFocusedCourseID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedCourseID = lastFocused
        }
    }
}
