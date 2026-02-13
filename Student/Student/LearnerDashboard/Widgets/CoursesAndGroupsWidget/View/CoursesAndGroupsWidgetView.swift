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

import Combine
import Core
import SwiftUI

struct CoursesAndGroupsWidgetView: View {
    @State var viewModel: CoursesAndGroupsWidgetViewModel

    var body: some View {
        ZStack {
            if viewModel.state == .data {
                DashboardTitledWidget(
                    viewModel.widgetTitle,
                    customAccessibilityTitle: viewModel.widgetAccessibilityTitle
                ) {
                    DashboardWidgetCard {
                        VStack(alignment: .leading, spacing: InstUI.Styles.Padding.sectionHeaderVertical.rawValue) {
                            if !viewModel.courseCards.isEmpty {
                                coursesSection
                            }

                            if !viewModel.groupCards.isEmpty {
                                groupsSection
                            }
                        }
                        .paddingStyle(.standard)
                    }
                }
                .animation(.dashboardWidget, value: viewModel.layoutIdentifier)
            }
        }
    }

    private var coursesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Courses", bundle: .student)
                .font(.semibold14, lineHeight: .fit)
                .foregroundStyle(.textDark)

            ForEach(viewModel.courseCards) { cardViewModel in
                CourseCardView(viewModel: cardViewModel)
            }
        }
    }

    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Groups", bundle: .student)
                .font(.semibold14, lineHeight: .fit)
                .foregroundStyle(.textDark)

            ForEach(viewModel.groupCards) { cardViewModel in
                GroupCardView(viewModel: cardViewModel)
            }
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var viewModel = makePreviewViewModel()

    CoursesAndGroupsWidgetView(viewModel: viewModel)
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
}

private func makePreviewViewModel() -> CoursesAndGroupsWidgetViewModel {
    let config = DashboardWidgetConfig(id: .coursesAndGroups, order: 0, isVisible: true, settings: nil)
    let interactor = CoursesAndGroupsWidgetInteractorMock()

    return CoursesAndGroupsWidgetViewModel(
        config: config,
        interactor: interactor,
        environment: PreviewEnvironment()
    )
}

#endif
