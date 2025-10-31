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

import HorizonUI
import SwiftUI

struct TimeSpentWidgetView: View {
    private let viewModel: TimeSpentWidgetViewModel

    init(viewModel: TimeSpentWidgetViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space8) {
            TimeSpentWidgetHeader()
                .accessibilityHidden(viewModel.state == .loading)
            switch viewModel.state {
            case .data, .loading:
                dataView
            case .empty:
                emptyView
            case .error:
                errorView
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .animation(.smooth, value: viewModel.selectedCourse)
        .shadow(
            color: Color.huiColors.primitives.grey125.opacity(0.18),
            radius: 4,
            x: 1,
            y: 2
        )
        .containerRelativeFrame(.horizontal)
        .isSkeletonLoadActive(viewModel.state == .loading)
        .accessibilityElement(children: viewModel.state == .loading ? .ignore : .contain)
        .accessibilityLabel(
            viewModel.state == .loading
                            ? Text(String(localized: "Time Spent View is loading", bundle: .horizon))
                            : nil
        )
        .onWidgetReload { _ in
            viewModel.getTimeSpent(ignoreCache: true)
        }
    }

    private var dataView: some View {
        HStack(spacing: .huiSpaces.space8) {
            Text(viewModel.selectedCourse?.formattedTime ?? "")
                .accessibilityLabel(Text(viewModel.selectedCourse?.accessibilityCourseTimeSpent ?? ""))
            if viewModel.isListCoursesVisiable {
                TimeSpentWidgetCourseListView(
                    courses: viewModel.courses,
                    selectedCourse: viewModel.selectedCourse
                ) { course in
                    viewModel.selectedCourse = course
                }
                .frame(minWidth: 150)
                .fixedSize(horizontal: true, vertical: false)
            }
            Spacer()
        }
    }

    private var emptyView: some View {
        WidgetEmptyView()
    }

    private var errorView: some View {
        WidgetErrorView {
            viewModel.getTimeSpent(ignoreCache: true)
        }
    }
}

#if DEBUG
#Preview {
    VStack(alignment: .leading) {
        TimeSpentWidgetAssembly
            .makePreview(
                showError: false,
                models: [
                    .init(id: "ID-1", courseName: "Introduction to SwiftUI", minutesPerDay: 125),
                    .init(id: "ID-2", courseName: "Advanced iOS Development", minutesPerDay: 90),
                    .init(id: "ID-3", courseName: "UI/UX Design Principles", minutesPerDay: 45),
                    .init(id: "ID-4", courseName: "Networking with URLSession", minutesPerDay: 60)
                ]
            )
        TimeSpentWidgetAssembly.makePreview(
            showError: false,
            models: [
                .init(id: "ID-1", courseName: "Introduction to SwiftUI", minutesPerDay: 125)
            ]
        )
        TimeSpentWidgetAssembly.makePreview(showError: false, models: [])
        TimeSpentWidgetAssembly.makePreview(showError: true, models: [])
    }
}
#endif
