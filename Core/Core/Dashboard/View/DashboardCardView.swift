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
    @ObservedObject var cards: DashboardCardsViewModel
    @ObservedObject var colors: Store<GetCustomColors>
    @ObservedObject var groups: Store<GetDashboardGroups>
    @ObservedObject var notifications: Store<GetAccountNotifications>
    @ObservedObject var settings: Store<GetUserSettings>
    @ObservedObject var conferencesViewModel = DashboardConferencesViewModel()
    @ObservedObject var invitationsViewModel = DashboardInvitationsViewModel()
    @ObservedObject var layoutViewModel = DashboardLayoutViewModel()

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var showGrade = AppEnvironment.shared.userDefaults?.showGradesOnDashboard == true

    private let shouldShowGroupList: Bool

    public init(shouldShowGroupList: Bool, showOnlyTeacherEnrollment: Bool) {
        self.cards = DashboardCardsViewModel(showOnlyTeacherEnrollment: showOnlyTeacherEnrollment)
        self.shouldShowGroupList = shouldShowGroupList
        let env = AppEnvironment.shared
        colors = env.subscribe(GetCustomColors())
        groups = env.subscribe(GetDashboardGroups())
        notifications = env.subscribe(GetAccountNotifications())
        settings = env.subscribe(GetUserSettings(userID: "self"))
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    CircleRefresh { endRefreshing in
                        refresh(force: true, onComplete: endRefreshing)
                    }
                    list(CGSize(width: geometry.size.width - 32, height: geometry.size.height))
                }
                    .padding(.horizontal, 16)
            }
        }
            .background(Color.backgroundLightest.edgesIgnoringSafeArea(.all))

            .navigationBarGlobal()
            .navigationBarItems(
                leading: Button(action: {
                    env.router.route(to: "/profile", from: controller, options: .modal())
                }, label: {
                    Image.hamburgerSolid
                        .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
                })
                    .identifier("Dashboard.profileButton")
                    .accessibility(label: Text("Profile Menu", bundle: .core)),

                trailing: Button(action: layoutViewModel.toggle) {
                    layoutViewModel.buttonImage
                        .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
                        .accessibility(label: Text(layoutViewModel.buttonA11yLabel))
                }
            )

            .onAppear { refresh(force: false) }
            .onReceive(NotificationCenter.default.publisher(for: .showGradesOnDashboardDidChange).receive(on: DispatchQueue.main)) { _ in
                showGrade = env.userDefaults?.showGradesOnDashboard == true
            }
    }

    @ViewBuilder func list(_ size: CGSize) -> some View {
        ForEach(conferencesViewModel.conferences, id: \.entity.id) { conference in
            ConferenceCard(conference: conference.entity, contextName: conference.contextName)
                .padding(.top, 16)
        }

        ForEach(invitationsViewModel.invitations, id: \.id) { (id, course, enrollment) in
            CourseInvitationCard(course: course, enrollment: enrollment, id: id)
                .padding(.top, 16)
        }

        ForEach(notifications.all, id: \.id) { notification in
            NotificationCard(notification: notification)
                .padding(.top, 16)
        }

        courseCards(size)

        groupCards
    }

    @ViewBuilder func courseCards(_ size: CGSize) -> some View {
        switch cards.state {
        case .loading:
            ZStack { CircleProgress() }
                .frame(minWidth: size.width, minHeight: size.height)
        case .data(let cards):
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
            .frame(width: size.width) // If we rotate from single view to split view then this HStack won't fill its parent, this fixes it.
            .padding(.top, 16).padding(.bottom, 8)

            let hideColorOverlay = settings.first?.hideDashcardColorOverlays == true
            let layoutInfo = layoutViewModel.layoutInfo(for: size.width)
            DashboardGrid(itemCount: cards.count, itemWidth: layoutInfo.cardWidth, spacing: layoutInfo.spacing, columnCount: layoutInfo.columns) { cardIndex in
                let card = cards[cardIndex]
                CourseCard(card: card, hideColorOverlay: hideColorOverlay, showGrade: showGrade, width: layoutInfo.cardWidth)
                    // outside the CourseCard, because that isn't observing colors
                    .accentColor(Color(card.color.ensureContrast(against: .white)))
                    .frame(minHeight: 160)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
        case .empty:
            EmptyPanda(.Teacher,
                title: Text("No Courses", bundle: .core),
                message: Text("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", bundle: .core)
            )
                .frame(minWidth: size.width, minHeight: size.height)
        case .error(let message):
            ZStack {
                Text(message)
                    .font(.regular16).foregroundColor(.textDanger)
                    .multilineTextAlignment(.center)
            }
                .frame(minWidth: size.width, minHeight: size.height)
        }
    }

    @ViewBuilder var groupCards: some View {
        let filteredGroups = groups.all.filter { $0.isActive }
        if !filteredGroups.isEmpty && shouldShowGroupList {
            Section(
                header: HStack(alignment: .lastTextBaseline) {
                    Text("Groups", bundle: .core)
                        .font(.heavy24).foregroundColor(.textDarkest)
                        .accessibility(addTraits: .isHeader)
                    Spacer()
                }
                    .padding(.top, 16).padding(.bottom, 8)) {
                ForEach(filteredGroups, id: \.id) { group in
                    GroupCard(group: group, course: group.course)
                        // outside the GroupCard, because that isn't observing colors
                        .accentColor(Color(group.color.ensureContrast(against: .white)))
                        .padding(.bottom, 16)
                }
            }
        }
    }

    func refresh(force: Bool, onComplete: (() -> Void)? = nil) {
        invitationsViewModel.refresh(force: force)
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
