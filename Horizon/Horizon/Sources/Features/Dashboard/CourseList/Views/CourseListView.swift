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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewController) private var viewController
    @State private var isShowHeader: Bool = true
    @State private var isShowDivider: Bool = false
    @State private var selectedStatus: CourseCardModel.CourseStatus = .all
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
                    viewModel.navigateToCourseDetails(course: course, viewController: viewController)
                } label: {
                    CourseCardView(course: course) { program in
                        viewModel.navigateProgram(id: program.id, viewController: viewController)
                    }
                }
            }
        }
    }

    private var courseFilterView: some View {
        HStack(spacing: .zero) {
            CourseFilteringView(selectedStatus: selectedStatus) { status in
                viewModel.filter(status: status ?? .all)
            }
            .frame(maxWidth: 200)
            .fixedSize(horizontal: true, vertical: false)

            Spacer()
            Text(viewModel.filteredCourses.count.description)
                .foregroundStyle(Color.huiColors.text.dataPoint)
                .huiTypography(.p1)
        }
        .padding(.horizontal, .huiSpaces.space16)
        .padding(.bottom, .huiSpaces.space16)
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
        ) { _, _ in }
    )
}
