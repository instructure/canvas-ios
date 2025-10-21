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
    // MARK: - Dependencies

    @Bindable private var viewModel: DashboardViewModel
    @Environment(\.viewController) private var viewController

    // MARK: - a11y

    @State private var isShowHeader: Bool = true
    @State private var lastFocusedElement: DashboardFocusableElement?
    @State private var restoreFocusTrigger: Bool = false
    @AccessibilityFocusState private var accessibilityFocusedElement: DashboardFocusableElement?

    // MARK: - Widgets

    private let courseListWidgetView: CourseListWidgetView
    private let skillsHighlightsWidgetView: SkillsHighlightsWidgetView
    private let skillsCountWidgetView: SkillsCountWidgetView
    private let announcementWidgetView: AnnouncementsListWidgetView
    @State private var widgetReloadHandlers: [WidgetReloadHandler] = []

    // MARK: - Init

    init(viewModel: DashboardViewModel) {
        self.viewModel = viewModel
        courseListWidgetView = CourseListWidgetAssembly.makeView()
        let skillViewModel = SkillsHighlightsWidgetAssembly.makeViewModel()
        skillsHighlightsWidgetView = SkillsHighlightsWidgetAssembly.makeView(viewModel: skillViewModel)
        skillsCountWidgetView = SkillsCountWidgetView(viewModel: skillViewModel)
        announcementWidgetView = AnnouncementsWidgetAssembly.makeView()
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
            .environment(\.dashboardLastFocusedElement, $lastFocusedElement)
            .environment(\.dashboardRestoreFocusTrigger, restoreFocusTrigger)
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
        .onDidAppear {
            viewModel.reloadUnreadBadges()

            if UIAccessibility.isVoiceOverRunning, lastFocusedElement != nil {
                UIAccessibility.post(notification: .screenChanged, argument: nil)
            }

            restoreFocusTrigger.toggle()
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
            navigationBarButtons
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space10)
        .padding(.bottom, .huiSpaces.space4)
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var navigationBarButtons: some View {
        HorizonUI.NavigationBar.Trailing(
            hasUnreadNotification: viewModel.hasUnreadNotification,
            hasUnreadInboxMessage: viewModel.hasUnreadInboxMessage,
            onNotebookDidTap: {
                lastFocusedElement = .notebookButton
                viewModel.notebookDidTap(viewController: viewController)
            },
            onNotificationDidTap: {
                lastFocusedElement = .notificationButton
                viewModel.notificationsDidTap(viewController: viewController)
            },
            onMailDidTap: {
                lastFocusedElement = .mailButton
                viewModel.mailDidTap(viewController: viewController)
            },
            focusedButton: $accessibilityFocusedElement,
            notebookFocusValue: .notebookButton,
            notificationFocusValue: .notificationButton,
            mailFocusValue: .mailButton
        )
        .onChange(of: restoreFocusTrigger) { _, _ in
            if let lastFocused = lastFocusedElement,
               [.notebookButton, .notificationButton, .mailButton].contains(lastFocused) {
                DispatchQueue.main.async {
                    accessibilityFocusedElement = lastFocused
                }
            }
        }
    }

    private var dataWidgetsView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: .huiSpaces.space12) {
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
