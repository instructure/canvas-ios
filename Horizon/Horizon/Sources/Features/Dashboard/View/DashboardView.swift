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
import HorizonUI
import SwiftUI

struct DashboardView: View {
    @Bindable private var viewModel: DashboardViewModel
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
            ),
            refreshAction: viewModel.reload
        ) { _ in
            LazyVStack(spacing: .zero) {
                ForEach(viewModel.nextUpViewModels) { nextUpViewModel in
                    VStack(alignment: .leading, spacing: .zero) {
                        Text(nextUpViewModel.name)
                            .huiTypography(.h1)
                            .foregroundStyle(Color.huiColors.text.title)
                            .padding(.top, .huiSpaces.space24)
                            .padding(.bottom, .huiSpaces.space16)

                        HorizonUI.ProgressBar(
                            progress: nextUpViewModel.progress,
                            size: .medium,
                            numberPosition: .outside
                        )

                        if let learningObjectCardViewModel = nextUpViewModel.learningObjectCardViewModel {
                            Text("Next Up", bundle: .horizon)
                                .huiTypography(.h3)
                                .foregroundStyle(Color.huiColors.text.title)
                                .padding(.top, .huiSpaces.space36)
                                .padding(.bottom, .huiSpaces.space12)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HorizonUI.LearningObjectCard(
                                status: "Default",
                                moduleTitle: learningObjectCardViewModel.moduleTitle,
                                learningObjectName: learningObjectCardViewModel.learningObjectName,
                                duration: learningObjectCardViewModel.estimatedTime,
                                type: learningObjectCardViewModel.type,
                                dueDate: learningObjectCardViewModel.dueDate
                            ) {
                                if let url = learningObjectCardViewModel.url {
                                    viewModel.navigateToCourseDetails(url: url, viewController: viewController)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, .huiSpaces.space24)
                }
            }
            .padding(.bottom, .huiSpaces.space16)
        }
        .toolbar(.hidden)
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .scrollIndicators(.hidden, axes: .vertical)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var navigationBar: some View {
        HStack(spacing: .zero) {
            HorizonUI.NavigationBar.Leading(logoURL: logoURL)
            Spacer()
            HorizonUI.NavigationBar.Trailing {
                viewModel.notebookDidTap(viewController: viewController)
            } onNotificationDidTap: {
                viewModel.notificationsDidTap()
            } onMailDidTap: {
                viewModel.mailDidTap(viewController: viewController)
            }
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.bottom, .huiSpaces.space4)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var nameLabel: some View {
        Text(viewModel.title)
            .huiTypography(.p1)
    }
}

#if DEBUG
#Preview {
    DashboardAssembly.makePreview()
}
#endif
