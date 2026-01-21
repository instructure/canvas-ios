//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct CourseListView: View {
    // MARK: - VO

    @State private var lastFocusedCourseID: String?
    @AccessibilityFocusState private var focusedCourseID: String?
    private let selectFilterFocusedID = "selectFilterFocusedID"

    // MARK: - Private variables

    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false
    @State private var selectedOption: OptionModel = .init(
        id: ProgressStatus.all.rawValue,
        name: String(localized: "All courses")
    )

    // MARK: - Dependencies

    let viewModel: CourseListViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .zero) {
                navigationBarHelperView
                if viewModel.filteredCourses.isEmpty {
                    CourseListEmptyView()
                } else {
                    coursesView
                }
                if viewModel.isSeeMoreButtonVisible {
                    seeMoreButton
                }
            }
            .padding(.horizontal, .huiSpaces.space16)
            .padding(.bottom, .huiSpaces.space24)
        }
        .toolbar(.hidden)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.huiColors.surface.pagePrimary)
        .safeAreaInset(edge: .top, spacing: .zero) { headerView }
        .animation(.linear, value: isShowHeader)
        .animation(.easeInOut, value: viewModel.filteredCourses.count)
        .onAppear { restoreFocusIfNeeded(after: 0.1) }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: .zero) {
            if isShowHeader {
                navigationBar
                    .padding([.horizontal, .bottom], .huiSpaces.space24)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            courseFilterView

            Rectangle()
                .fill(Color.huiColors.primitives.grey14)
                .frame(height: 1.5)
                .hidden(!isShowDivider)
        }
        .padding(.top, .huiSpaces.space8)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var coursesView: some View {
        VStack(spacing: .huiSpaces.space16) {
            ForEach(viewModel.filteredCourses) { course in
                Button {
                    lastFocusedCourseID = course.id
                    viewModel.navigateToCourseDetails(course: course, viewController: viewController)
                } label: {
                    CourseCardView(course: course) { program in
                        lastFocusedCourseID = course.id
                        viewModel.navigateProgram(id: program.id, viewController: viewController)
                    }
                    .accessibilityActions {
                        Button("Open course") {
                            viewModel.navigateToCourseDetails(course: course, viewController: viewController)
                        }

                        ForEach(course.programs) { program in
                            Button {
                                viewModel.navigateProgram(id: program.id, viewController: viewController)
                            } label: {
                                Text(course.viewProgramAccessibilityString(program.name))
                            }
                        }
                    }
                }
                .accessibilityFocused($focusedCourseID, equals: course.id)
                .buttonStyle(.plain)
                .accessibilityRemoveTraits(.isButton)
            }
        }
    }

    private var courseFilterView: some View {
        HStack(spacing: .zero) {
            filterView
            Spacer()
            Text(viewModel.filteredCourses.count.description)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p1)
                .accessibilityLabel(Text(String(format: String(localized: "Count of visible items is %@"), viewModel.filteredCourses.count.description)))
        }
        .padding(.horizontal, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space16)
    }

    private var filterView: some View {
        FilterView(
            items: ProgressStatus.courses,
            selectedOption: selectedOption
        ) { option in
            viewModel.filter(status: .init(rawValue: option?.id ?? 0))
            lastFocusedCourseID = selectFilterFocusedID
            restoreFocusIfNeeded(after: 1)
            selectedOption = option ?? selectedOption
        }
        .id(selectFilterFocusedID)
        .accessibilityFocused($focusedCourseID, equals: selectFilterFocusedID)
    }

    private var navigationBarHelperView: some View {
        Color.clear
            .frame(height: 1)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
                isShowDivider = frame.minY < 100
            }
    }

    private var navigationBar: some View {
        TitleBar(
            onBack: { _ in dismiss() },
            onClose: nil
        ) {
            Text("All courses", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .accessibilityAddTraits(.isHeader)
        }
    }

    private var seeMoreButton: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Show more", bundle: .horizon),
            type: .whiteGrayOutline,
            isSmall: true,
            fillsWidth: true
        ) {
            viewModel.seeMore()
        }
        .accessibilityLabel(String(localized: "Show more"))
        .accessibilityHint( String(localized: "Double tap to load more courses"))
        .padding(.top, .huiSpaces.space16)
    }

    private func restoreFocusIfNeeded(after: Double) {
        guard let lastFocused = lastFocusedCourseID else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            focusedCourseID = lastFocused
        }
    }
}

#Preview {
    CourseListView(
        viewModel: .init(
            courses: [
                .init(course: .init(id: "1", name: "Course111", progress: 100)),
                .init(course: .init(id: "2", name: "Course111", progress: 20)),
                .init(course: .init(id: "3", name: "Course111", progress: 0)),
                .init(course: .init(id: "4", name: "Course111", progress: 12)),
                .init(course: .init(id: "5", name: "Course111", progress: 90)),
                .init(course: .init(id: "6", name: "Course111", progress: 100)),
                .init(course: .init(id: "7", name: "Course111", progress: 0)),
                .init(course: .init(id: "8", name: "Course111", progress: 80)),
                .init(course: .init(id: "9", name: "Course111", progress: 0)),
                .init(course: .init(id: "10", name: "Course111", progress: 90)),
                .init(course: .init(id: "11", name: "Course111", progress: 100)),
                .init(course: .init(id: "12", name: "Course111", progress: 30))
            ],
            router: AppEnvironment.shared.router
        )
    )
}
