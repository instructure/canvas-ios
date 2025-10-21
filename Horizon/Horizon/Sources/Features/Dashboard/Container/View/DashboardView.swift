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
    @State private var isShowHeader: Bool = true
    @State private var widgetReloadHandlers: [WidgetReloadHandler] = []

    // MARK: - Widgets

    private let courseListWidgetView: CourseListWidgetView
    private let skillsHighlightsWidgetView: SkillsHighlightsWidgetView
    private let skillsCountWidgetView: SkillsCountWidgetView
    private let announcementWidgetView: AnnouncementsListWidgetView
    private let timeSpentWidgetView: TimeSpentWidgetView
    private let completedWidgetView: CompletedWidgetView

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        courseListWidgetView = CourseListWidgetAssembly.makeView()
        let skillViewModel = SkillsHighlightsWidgetAssembly.makeViewModel()
        skillsHighlightsWidgetView = SkillsHighlightsWidgetAssembly.makeView(viewModel: skillViewModel)
        skillsCountWidgetView = SkillsCountWidgetView(viewModel: skillViewModel)
        announcementWidgetView = AnnouncementsWidgetAssembly.makeView()
        timeSpentWidgetView = TimeSpentWidgetAssembly.makeView()
        completedWidgetView = CompletedWidgetAssembly.makeView()
    }

    var body: some View {
        InstUI.BaseScreen(
            state: .data,
            config: .init(
                refreshable: true,
                loaderBackgroundColor: .huiColors.surface.pagePrimary
            ),
            refreshAction: refreshWidgets
        ) { _ in
            VStack(spacing: .zero) {
                navigationBarHelperView
                announcementWidgetView
                courseListWidgetView
                dataWidgetsView
                skillsHighlightsWidgetView
            }
            .padding(.bottom, .huiSpaces.space24)
        }
        .captureWidgetReloadHandlers($widgetReloadHandlers)
        .safeAreaInset(edge: .top, spacing: .zero) {
            if isShowHeader {
                navigationBar
                    .toolbar(.hidden)
                    .transition(.move(edge: .top).combined(with: .opacity))
            } else {
                Rectangle()
                    .fill(Color.huiColors.surface.pagePrimary)
                    .frame(height: 55)
                    .ignoresSafeArea()
            }
        }
        .scrollIndicators(.hidden, axes: .vertical)
        .background(Color.huiColors.surface.pagePrimary)
        .animation(.linear, value: isShowHeader)
        .onAppear {
            viewModel.reloadUnreadBadges()
        }
    }

    func refreshWidgets(completion: @escaping () -> Void) {
        widgetReloadHandlers.forEach { $0.handler {} }
        completion()
    }

    private var navigationBarHelperView: some View {
        Color.clear
            .frame(height: 16)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
            }
    }

    private var navigationBar: some View {
        HStack(spacing: .zero) {
            InstitutionLogo()
            Spacer()
            HorizonUI.NavigationBar.Trailing(
                hasUnreadNotification: viewModel.hasUnreadNotification,
                hasUnreadInboxMessage: viewModel.hasUnreadInboxMessage,
                onNotebookDidTap: {
                    viewModel.notebookDidTap(viewController: viewController)
                },
                onNotificationDidTap: {
                    viewModel.notificationsDidTap(viewController: viewController)
                },
                onMailDidTap: {
                    viewModel.mailDidTap(viewController: viewController)
                }
            )
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space10)
        .padding(.bottom, .huiSpaces.space4)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var dataWidgetsView: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: .huiSpaces.space12) {
                completedWidgetView
                timeSpentWidgetView
                skillsCountWidgetView
            }
            .padding(.top, .huiSpaces.space2)
            .padding(.bottom, .huiSpaces.space4)
            .padding(.horizontal, .huiSpaces.space24)
        }
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
        .padding(.top, .huiSpaces.space24)
    }
}

#if DEBUG
    #Preview {
        DashboardAssembly.makePreview()
    }
#endif
