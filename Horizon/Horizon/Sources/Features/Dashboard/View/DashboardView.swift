//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import SwiftUI
import HorizonUI

struct DashboardView: View {
    @ObservedObject private var viewModel: DashboardViewModel
    @Environment(\.viewController) private var viewController

    // TODO: - Set with correct url later
    private let logoURL = "https://cdn.prod.website-files.com/5f7685be6c8c113f558855d9/62c87dbd6208a1e98e89e707_Logo_Canvas_Red_Vertical%20copy.png"

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(
                refreshable: true,
                loaderBackgroundColor: .huiColors.surface.pagePrimary
            )
        ) { _ in
            LazyVStack(spacing: .zero) {
                ForEach(viewModel.courses) { course in
                    if course.currentModuleItem != nil, !course.upcomingModuleItems.isEmpty {
                        VStack(alignment: .leading, spacing: .zero) {
                            Text(course.name)
                                .huiTypography(.h1)
                                .foregroundStyle(Color.huiColors.text.title)
                                .padding(.top, .huiSpaces.primitives.medium)
                                .padding(.bottom, .huiSpaces.primitives.mediumSmall)

                            HorizonUI.ProgressBar(
                                progress: course.progress,
                                size: .medium,
                                numberPosition: .outside
                            )
                            if let module = course.currentModule, let moduleItem = course.currentModuleItem {
                                Text("Next Up", bundle: .horizon)
                                    .huiTypography(.h3)
                                    .foregroundStyle(Color.huiColors.text.title)
                                    .padding(.top, .huiSpaces.primitives.large)
                                    .padding(.bottom, .huiSpaces.primitives.small)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                HorizonUI.LearningObjectCard(
                                    status: "Default",
                                    moduleTitle: module.name,
                                    learningObjectName: moduleItem.title,
                                    duration: "20 Mins",
                                    type: moduleItem.type?.label,
                                    dueDate: moduleItem.dueAt?.relativeShortDateOnlyString
                                ) {
                                    if let url = moduleItem.htmlURL {
                                        viewModel.navigateToCourseDetails(url: url, viewController: viewController)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, .huiSpaces.primitives.medium)
                    }
                }
            }
            .padding(.bottom, .huiSpaces.primitives.mediumSmall)
        }
        .navigationBarItems(leading: HorizonUI.NavigationBar.Leading(logoURL: logoURL))
        .navigationBarItems(trailing: HorizonUI.NavigationBar.Trailing {
            viewModel.notebookDidTap(controller: viewController)
        } onNotificationDidTap: {
            viewModel.notificationsDidTap()
        } onMailDidTap: {
            viewModel.mailDidTap()
        })
        .scrollIndicators(.hidden, axes: .vertical)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var nameLabel: some View {
        Size16RegularTextDarkestTitle(title: viewModel.title)
    }
}

#if DEBUG
#Preview {
    DashboardAssembly.makePreview()
}
#endif
