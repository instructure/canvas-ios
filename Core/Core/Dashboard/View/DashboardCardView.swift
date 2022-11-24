//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import SwiftUI

public struct DashboardCardView: View {
    @StateObject var viewModel: DashboardViewModel
    @ObservedObject var cards: DashboardCardsViewModel
    @ObservedObject var colors: Store<GetCustomColors>
    @ObservedObject var groups: Store<GetDashboardGroups>
    @ObservedObject var notifications: Store<GetAccountNotifications>
    @ObservedObject var settings: Store<GetUserSettings>
    @ObservedObject var conferencesViewModel = DashboardConferencesViewModel()
    @ObservedObject var invitationsViewModel = DashboardInvitationsViewModel()
    @ObservedObject var layoutViewModel: DashboardLayoutViewModel
    @ObservedObject var fileUploadNotificationCardViewModel = FileUploadNotificationCardListViewModel()

    @Environment(\.scenePhase) var scenePhase
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var showGrade = AppEnvironment.shared.userDefaults?.showGradesOnDashboard == true

    private var activeGroups: [Group] { groups.all.filter { $0.isActive } }
    private var isGroupSectionActive: Bool { !activeGroups.isEmpty && shouldShowGroupList }
    private let shouldShowGroupList: Bool
    private let verticalSpacing: CGFloat = 16

    public init(shouldShowGroupList: Bool, showOnlyTeacherEnrollment: Bool) {
        cards = DashboardCardsViewModel(showOnlyTeacherEnrollment: showOnlyTeacherEnrollment)
        self.shouldShowGroupList = shouldShowGroupList
        let env = AppEnvironment.shared
        layoutViewModel = DashboardLayoutViewModel(interactor: DashboardSettingsInteractorLive(environment: env, defaults: env.userDefaults!))
        colors = env.subscribe(GetCustomColors())
        groups = env.subscribe(GetDashboardGroups())
        notifications = env.subscribe(GetAccountNotifications())
        settings = env.subscribe(GetUserSettings(userID: "self"))
        _viewModel = StateObject(wrappedValue: DashboardViewModel(environment: env))
    }

    public var body: some View {
        GeometryReader { geometry in
            RefreshableScrollView {
                VStack(spacing: 0) {
                    fileUploadNotificationCards()
                    list(CGSize(width: geometry.size.width - 32, height: geometry.size.height))
                }
                .padding(.horizontal, verticalSpacing)
            }
            refreshAction: { onComplete in
                refresh(force: true, onComplete: onComplete)
            }
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .navigationBarGlobal()
        .navigationBarItems(leading: menuButton, trailing: settingsButton)
        .onAppear {
            refresh(force: false) {
                let env = AppEnvironment.shared
                if env.userDefaults?.interfaceStyle == nil, env.currentSession?.isFakeStudent == false {
                    controller.value.showThemeSelectorAlert()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            fileUploadNotificationCardViewModel.sceneDidBecomeActive.send(())
        }
        .onReceive(NotificationCenter.default.publisher(for: .showGradesOnDashboardDidChange).receive(on: DispatchQueue.main)) { _ in
            withAnimation {
                showGrade = env.userDefaults?.showGradesOnDashboard == true
            }
        }
        .onReceive(invitationsViewModel.coursesChanged) { _ in refresh(force: true) }
        .onReceive(viewModel.showSettings) { event in
            showSettings(event.view, viewSize: event.viewSize)
        }
    }

    private func showSettings(_ settingsViewController: UIViewController, viewSize: CGSize) {
        settingsViewController.preferredContentSize = viewSize
        settingsViewController.modalPresentationStyle = .popover

        // Position the popover's arrow to point to the settings button
        if let popoverController = settingsViewController.popoverPresentationController {
            var navButtonView = controller.value.navigationItem.rightBarButtonItem?.customView

            if navButtonView == nil,
               #available(iOS 16.0, *),
               let trailingView = controller.value.navigationItem.trailingItemGroups.first?.barButtonItems.first?.customView {
                navButtonView = trailingView
            }

            popoverController.sourceView = navButtonView
            popoverController.sourceRect = CGRect(x: 26, y: 35, width: 0, height: 0)

            if #unavailable(iOS 15) {
                // Center the arrow on iOS 14
                popoverController.sourceRect = popoverController.sourceRect.offsetBy(dx: -4, dy: 0)
            }
        }

        env.router.show(
            settingsViewController,
            from: controller,
            options: .modal(.popover),
            analyticsRoute: "/dashboard/settings"
        )
    }

    private func setStyle(style: UIUserInterfaceStyle?) {
        env.userDefaults?.interfaceStyle = style
        if let window = env.window {
            window.updateInterfaceStyle(style)
        }
    }

    private var menuButton: some View {
        Button(action: {
            env.router.route(to: "/profile", from: controller, options: .modal())
        }) {
            Image.hamburgerSolid
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
        .identifier("Dashboard.profileButton")
        .accessibility(label: Text("Profile Menu", bundle: .core))
    }

    @ViewBuilder
    private var settingsButton: some View {
        if cards.shouldShowSettingsButton {
            Button {
                guard controller.value.presentedViewController == nil else {
                    controller.value.presentedViewController?.dismiss(animated: true)
                    return
                }

                viewModel.settingsButtonTapped.send(())
            } label: {
                Image.settingsLine
                    .foregroundColor(Color(Brand.shared.navTextColor))
            }
            .frame(width: 44, height: 44).padding(.trailing, -6)
            .accessibilityLabel(Text("Dashboard settings", bundle: .core))
        }
    }

    @ViewBuilder func fileUploadNotificationCards() -> some View {
        ForEach(fileUploadNotificationCardViewModel.items) { viewModel in
            if !viewModel.isHiddenByUser {
                FileUploadNotificationCard(viewModel: viewModel)
                    .frame(maxWidth: .infinity)
                    .padding(.top, verticalSpacing)
                    .transition(.move(edge: .top))
            }
        }
    }

    @ViewBuilder func list(_ size: CGSize) -> some View {
        ForEach(conferencesViewModel.conferences, id: \.entity.id) { conference in
            ConferenceCard(conference: conference.entity, contextName: conference.contextName)
                .padding(.top, verticalSpacing)
        }

        ForEach(invitationsViewModel.items) { invitation in
            CourseInvitationCard(invitation: invitation)
                .padding(.top, verticalSpacing)
        }

        ForEach(notifications.all, id: \.id) { notification in
            NotificationCard(notification: notification)
                .padding(.top, verticalSpacing)
        }

        courseCards(size)

        groupCards
    }

    @ViewBuilder func courseCards(_ size: CGSize) -> some View {
        switch cards.state {
        case .loading:
            ZStack {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
            }
            .frame(minWidth: size.width, minHeight: size.height)
        case .data(let cards):
            coursesHeader(width: size.width)

            let hideColorOverlay = settings.first?.hideDashcardColorOverlays == true
            let layoutInfo = layoutViewModel.layoutInfo(for: size.width)
            DashboardGrid(itemCount: cards.count, itemWidth: layoutInfo.cardWidth, spacing: layoutInfo.spacing, columnCount: layoutInfo.columns) { cardIndex in
                let card = cards[cardIndex]
                CourseCard(card: card, hideColorOverlay: hideColorOverlay, showGrade: showGrade, width: layoutInfo.cardWidth, contextColor: card.color)
                    // outside the CourseCard, because that isn't observing colors
                    .accentColor(Color(card.color))
                    .frame(minHeight: 160)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
        case .empty:
            coursesHeader(width: size.width)
            InteractivePanda(scene: ConferencesPanda(), title: Text("No Courses", bundle: .core), subtitle: Text("It looks like you aren't enrolled in any courses.", bundle: .core))
                .padding(.top, 50)
                .padding(.bottom, 50 - verticalSpacing) // group header already has a top padding
        case .error(let message):
            ZStack {
                Text(message)
                    .font(.regular16).foregroundColor(.textDanger)
                    .multilineTextAlignment(.center)
            }
            .frame(minWidth: size.width, minHeight: size.height)
        }
    }

    private func coursesHeader(width: CGFloat) -> some View {
        HStack(alignment: .lastTextBaseline) {
            Text("Courses", bundle: .core)
                .font(.heavy24).foregroundColor(.textDarkest)
                .accessibility(identifier: "dashboard.courses.heading-lbl")
                .accessibility(addTraits: .isHeader)
            Spacer()
            Button(action: showAllCourses) {
                Text("Edit Dashboard", bundle: .core)
                    .font(.semibold16).foregroundColor(Color(Brand.shared.linkColor))
            }.identifier("Dashboard.editButton")
        }
        .frame(width: width) // If we rotate from single view to split view then this HStack won't fill its parent, this fixes it.
        .padding(.top, verticalSpacing).padding(.bottom, verticalSpacing / 2)
    }

    @ViewBuilder var groupCards: some View {
        if isGroupSectionActive {
            Section(
                header: HStack(alignment: .lastTextBaseline) {
                    Text("Groups", bundle: .core)
                        .font(.heavy24).foregroundColor(.textDarkest)
                        .accessibility(addTraits: .isHeader)
                    Spacer()
                }
                .padding(.top, verticalSpacing).padding(.bottom, verticalSpacing / 2)) {
                let filteredGroups = activeGroups
                ForEach(filteredGroups, id: \.id) { group in
                    GroupCard(group: group, course: group.course)
                        // outside the GroupCard, because that isn't observing colors
                        .accentColor(Color(group.color.ensureContrast(against: .white)))
                        .padding(.bottom, verticalSpacing)
                }
            }
        }
    }

    func refresh(force: Bool, onComplete: (() -> Void)? = nil) {
        invitationsViewModel.refresh()
        colors.refresh(force: force)
        conferencesViewModel.refresh(force: force)
        groups.exhaust(force: force)
        notifications.exhaust(force: force)
        settings.refresh(force: force)
        cards.refresh(onComplete: onComplete)
    }

    func showAllCourses() {
        env.router.route(to: "/courses", from: controller)
    }
}
