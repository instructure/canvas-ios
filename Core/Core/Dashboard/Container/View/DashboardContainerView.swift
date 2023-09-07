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

public struct DashboardContainerView: View, ScreenViewTrackable, DownloadsProgressBarHidden {

    @Injected(\.reachability) var reachability: ReachabilityProvider

    @StateObject var viewModel: DashboardContainerViewModel
    @ObservedObject var courseCardListViewModel: DashboardCourseCardListViewModel
    @ObservedObject var colors: Store<GetCustomColors>
    @ObservedObject var groups: Store<GetDashboardGroups>
    @ObservedObject var notifications: Store<GetAccountNotifications>
    @ObservedObject var settings: Store<GetUserSettings>
    @ObservedObject var conferencesViewModel = DashboardConferencesViewModel()
    @ObservedObject var invitationsViewModel = DashboardInvitationsViewModel()
    @ObservedObject var layoutViewModel: DashboardLayoutViewModel
    @ObservedObject var fileUploadNotificationCardViewModel = FileUploadNotificationCardListViewModel()
    @ObservedObject private var offlineModeViewModel: OfflineModeViewModel

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public var screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/")

    @State private var isShowingKebabDialog = false
    @State var showGrade = AppEnvironment.shared.userDefaults?.showGradesOnDashboard == true
    @StateObject private var offlineSyncCardViewModel = DashboardOfflineSyncProgressCardAssembly.makeViewModel()

    private var activeGroups: [Group] { groups.all.filter { $0.isActive } }
    private var isGroupSectionActive: Bool { !activeGroups.isEmpty && shouldShowGroupList }
    private let shouldShowGroupList: Bool
    private let verticalSpacing: CGFloat = 16

    public init(shouldShowGroupList: Bool,
                showOnlyTeacherEnrollment: Bool,
                offlineViewModel: OfflineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())) {
        courseCardListViewModel = DashboardCourseCardListAssembly.makeDashboardCourseCardListViewModel(showOnlyTeacherEnrollment: showOnlyTeacherEnrollment)
        self.shouldShowGroupList = shouldShowGroupList
        let env = AppEnvironment.shared
        layoutViewModel = DashboardLayoutViewModel(interactor: DashboardSettingsInteractorLive(environment: env, defaults: env.userDefaults))
        colors = env.subscribe(GetCustomColors())
        groups = env.subscribe(GetDashboardGroups())
        notifications = env.subscribe(GetAccountNotifications())
        settings = env.subscribe(GetUserSettings(userID: "self"))
        _viewModel = StateObject(wrappedValue: DashboardContainerViewModel(environment: env))
        self.offlineModeViewModel = offlineViewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            RefreshableScrollView {
                VStack(spacing: 0) {
                    DashboardOfflineSyncProgressCardView(viewModel: offlineSyncCardViewModel)
                    fileUploadNotificationCards()
                    if !reachability.isConnected {
                        DownloadedContentCellView {
                            showDownloads()
                        }
                    }
                    list(CGSize(width: geometry.size.width - 32, height: geometry.size.height))
                }
                .animation(.default, value: offlineSyncCardViewModel.isVisible)
                .padding(.horizontal, verticalSpacing)
            }
            refreshAction: { onComplete in
                refresh(force: true, onComplete: onComplete)
            }
        }
        .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))
        .navigationBarGlobal()
        .navigationBarItems(leading: profileMenuButton, trailing: rightNavBarButtons)
        .onAppear {
            refresh(force: false) {
                let env = AppEnvironment.shared
                if env.userDefaults?.interfaceStyle == nil, env.currentSession?.isFakeStudent == false {
                    controller.value.showThemeSelectorAlert()
                }
            }
            NotificationCenter.default.post(name: .DownloadContentClosed, object: nil)
            toggleDownloadingBarView(hidden: false)
        }
        .onDisappear {
            if UIDevice.current.userInterfaceIdiom == .pad {
                toggleDownloadingBarView(hidden: true)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            fileUploadNotificationCardViewModel.sceneDidBecomeActive.send()
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
        }

        env.router.show(
            settingsViewController,
            from: controller,
            options: .modal(.popover),
            analyticsRoute: "/dashboard/settings"
        )
    }

    // MARK: - Nav Bar Buttons

    private var profileMenuButton: some View {
        Button {
            env.router.route(to: "/profile", from: controller, options: .modal())
        } label: {
            Image.hamburgerSolid
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
        .identifier("Dashboard.profileButton")
        .accessibility(label: Text("Profile Menu", bundle: .core))
    }

    @ViewBuilder
    private var rightNavBarButtons: some View {
        if courseCardListViewModel.shouldShowSettingsButton {
            if offlineModeViewModel.isOfflineFeatureEnabled, env.app == .student {
                optionsKebabButton
            } else {
                dashboardSettingsButton
            }
        }
    }

    @ViewBuilder
    private var optionsKebabButton: some View {
        Button {
            // Dismiss dashboard settings popover
            guard controller.value.presentedViewController == nil else {
                controller.value.presentedViewController?.dismiss(animated: true)
                return
            }

            isShowingKebabDialog.toggle()
        } label: {
            Image.moreSolid
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.trailing, -6)
        .accessibilityLabel(Text("Dashboard Options", bundle: .core))
        .confirmationDialog("", isPresented: $isShowingKebabDialog) {
            Button {
                env.router.route(to: "/offline/sync_picker", from: controller, options: .modal(isDismissable: false, embedInNav: true))
            } label: {
                Text("Manage Offline Content", bundle: .core)
            }
            Button {
                guard controller.value.presentedViewController == nil else {
                    controller.value.presentedViewController?.dismiss(animated: true)
                    return
                }
                viewModel.settingsButtonTapped.send()
            } label: {
                Text("Edit Dashboard", bundle: .core)
            }
        }
    }

    @ViewBuilder
    private var dashboardSettingsButton: some View {
        Button {
            guard controller.value.presentedViewController == nil else {
                controller.value.presentedViewController?.dismiss(animated: true)
                return
            }

            viewModel.settingsButtonTapped.send()
        } label: {
            Image.settingsLine
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.trailing, -6)
        .accessibilityLabel(Text("Dashboard settings", bundle: .core))
        .accessibilityIdentifier("Dashboard.settingsButton")
    }

    // MARK: Nav Bar Buttons -

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

        // This is to prevent the bottom card sticking to the tab bar
        Color.clear
            .frame(height: verticalSpacing)
    }

    @ViewBuilder func courseCards(_ size: CGSize) -> some View {
        switch courseCardListViewModel.state {
        case .loading:
            ZStack {
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
            }
            .frame(minWidth: size.width, minHeight: size.height)
        case .data:
            let courseCardList = courseCardListViewModel.courseCardList
            coursesHeader(width: size.width)

            let hideColorOverlay = settings.first?.hideDashcardColorOverlays == true
            let layoutInfo = layoutViewModel.layoutInfo(for: size.width, horizontalSizeClass: horizontalSizeClass)
            DashboardGrid(
                itemCount: courseCardList.count,
                itemWidth: layoutInfo.cardWidth,
                spacing: layoutInfo.spacing,
                columnCount: layoutInfo.columns
            ) { cardIndex in
                let card = courseCardList[cardIndex]
                let availabilityBinding = Binding<Bool>(
                    get: { !offlineModeViewModel.isOffline || (card.isAvailableOffline && offlineModeViewModel.isOffline) },
                    set: { _ in }
                )
                DashboardCourseCardView(
                    courseCard: card,
                    hideColorOverlay: hideColorOverlay,
                    showGrade: showGrade,
                    width: layoutInfo.cardWidth,
                    contextColor: card.color,
                    isWideLayout: layoutInfo.isWideLayout,
                    isAvailable: availabilityBinding
                )
                .frame(minHeight: layoutInfo.cardMinHeight)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
        case .empty:
            coursesHeader(width: size.width)
            InteractivePanda(scene: ConferencesPanda(), title: Text("No Courses", bundle: .core), subtitle: Text("It looks like you aren't enrolled in any courses.", bundle: .core))
                .padding(.top, 50)
                .padding(.bottom, 50 - verticalSpacing) // group header already has a top padding
        case .error:
            ZStack {
                Text("Something went wrong")
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
            PrimaryButton(isAvailable: !$offlineModeViewModel.isOffline, action: showAllCourses) {
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
                    GroupCard(group: group, course: group.course, isAvailable: !$offlineModeViewModel.isOffline)
                        .padding(.bottom, filteredGroups.last != group ? verticalSpacing : 0)
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
        courseCardListViewModel.refresh(onComplete: onComplete)
    }

    func showAllCourses() {
        env.router.route(to: "/courses", from: controller)
    }

    func showDownloads() {
        let downloadsViewHostingController = CoreHostingController(DownloadsView())
        env.router.show(
            downloadsViewHostingController,
            from: controller,
            options: .push
        )
    }
}
