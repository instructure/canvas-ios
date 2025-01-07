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
            config: .init(refreshable: true)
        ) { _ in
            VStack(spacing: 0) {
                ForEach(viewModel.courses) { course in
                    if course.currentModuleItem != nil, !course.upcomingModuleItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Size24BoldTextDarkestTitle(title: course.name)
                                .padding(.top, 16)
                            CertificateProgressBar(
                                progress: course.progress,
                                progressString: course.progressString
                            )
                            moduleView(course: course)
                        }
                        .padding(.horizontal, 16)
                        .background()
                    }
                }
            }
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
        .background(Color.backgroundLight)
    }

    private var nameLabel: some View {
        Size16RegularTextDarkestTitle(title: viewModel.title)
    }

    @ViewBuilder
    private func moduleView(course: HCourse) -> some View {
        if let module = course.currentModule, let moduleItem = course.currentModuleItem {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    AsyncImage(url: course.imageURL) { image in
                        image.image?.resizable().scaledToFill()
                    }
                    .frame(width: proxy.size.width)
                    .cornerRadius(8)
                }
                .frame(height: 200)
                .padding(.vertical, 24)

                Size24RegularTextDarkestTitle(title: module.name)
                    .padding(.bottom, 8)
                HStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Image(systemName: "document")
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color.textDark)
                            .frame(width: 18, height: 18)
                        Size12RegularTextDarkTitle(title: moduleItem.title)
                            .lineLimit(2)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(Color.textDark)
                            .frame(width: 14, height: 14)
                        Size12RegularTextDarkTitle(title: "20 Mins")
                    }
                }
                Button {
                    if let url = moduleItem.htmlURL {
                        AppEnvironment.shared.router.route(to: url, from: viewController)
                    }
                } label: {
                    Text("Continue learning")
                        .font(.regular14)
                        .frame(height: 36)
                        .frame(maxWidth: .infinity)
                        .background(Color.backgroundLight)
                        .foregroundColor(Color.textDark)
                        .cornerRadius(8)
                        .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, 16)
            .background(Color.backgroundLightest)
            .cornerRadius(8)
            .padding(.vertical, 16)
        }
    }
}

#if DEBUG
#Preview {
    DashboardAssembly.makePreview()
}
#endif
