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
    @ObservedObject var cards: Store<GetDashboardCards>
    @ObservedObject var colors: Store<GetCustomColors>
    @ObservedObject var conferences: Store<GetLiveConferences>
    @ObservedObject var courses: Store<GetCourses>
    @ObservedObject var groups: Store<GetDashboardGroups>
    @ObservedObject var invitations: Store<GetCourseInvitations>
    @ObservedObject var notifications: Store<GetAccountNotifications>
    @ObservedObject var settings: Store<GetUserSettings>

    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var controller

    @State var needsRefresh = false
    @State var showGrade = AppEnvironment.shared.userDefaults?.showGradesOnDashboard == true

    public init() {
        let env = AppEnvironment.shared
        cards = env.subscribe(GetDashboardCards())
        colors = env.subscribe(GetCustomColors())
        conferences = env.subscribe(GetLiveConferences())
        courses = env.subscribe(GetCourses(enrollmentState: nil))
        groups = env.subscribe(GetDashboardGroups())
        invitations = env.subscribe(GetCourseInvitations())
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
                    Icon.hamburgerSolid
                        .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
                })
                    .identifier("Dashboard.profileButton")
                    .accessibility(label: Text("Profile Menu", bundle: .core)),

                trailing: Button(action: {
                    env.router.route(to: "/courses", from: controller)
                }, label: {
                    Text("Edit", bundle: .core).fontWeight(.regular)
                        .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
                })
                    .identifier("Dashboard.editButton")
            )

            .onAppear { refresh(force: false) }
            .onReceive(NotificationCenter.default.publisher(for: .favoritesDidChange).receive(on: DispatchQueue.main)) { _ in
                if cards.pending {
                    needsRefresh = true
                } else {
                    refreshCards()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .showGradesOnDashboardDidChange).receive(on: DispatchQueue.main)) { _ in
                showGrade = env.userDefaults?.showGradesOnDashboard == true
            }
    }

    @ViewBuilder func list(_ size: CGSize) -> some View {
        ForEach(conferences.all, id: \.id) { conference in
            if let contextName = conference.context.contextType == .group ?
                groups.first(where: { $0.id == conference.context.id })?.name :
                courses.first(where: { $0.id == conference.context.id })?.name {
                ConferenceCard(conference: conference, contextName: contextName)
                    .padding(.top, 16)
            }
        }

        ForEach(invitations.all, id: \.id) { enrollment in
            if let id = enrollment.id, let course = courses.first(where: { "course_\($0.id)" == enrollment.canvasContextID }) {
                CourseInvitationCard(course: course, enrollment: enrollment, id: id)
                    .padding(.top, 16)
            }
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
        case .data:
            Section(
                header: HStack(alignment: .lastTextBaseline) {
                    Text("Courses", bundle: .core)
                        .font(.heavy24).foregroundColor(.textDarkest)
                        .accessibility(identifier: "dashboard.courses.heading-lbl")
                    Spacer()
                    Button(action: showAllCourses, label: {
                        Text("All Courses", bundle: .core)
                            .font(.semibold16).foregroundColor(Color(Brand.shared.linkColor))
                    }).accessibility(identifier: "dashboard.courses.see-all-btn")
                }
                    .padding(.top, 16).padding(.bottom, 8)
            ) {
                let minCardWidth: CGFloat = 150
                let spacing: CGFloat = 16
                let columns = max(2, floor(size.width / minCardWidth))
                let cardSize = CGSize(width: (size.width - ((columns-1) * spacing)) / columns, height: 160)
                JustifiedGrid(cards.all, id: \.id, itemSize: cardSize, spacing: spacing, width: size.width) { card in
                    CourseCard(
                        card: card,
                        hideColorOverlay: settings.first?.hideDashcardColorOverlays == true,
                        showGrade: showGrade,
                        width: cardSize.width
                    )
                        // outside the CourseCard, because that isn't observing colors
                        .accentColor(Color(card.color.ensureContrast(against: .white)))
                }
            }
        case .empty:
            EmptyPanda(.Teacher,
                title: Text("No Courses", bundle: .core),
                message: Text("It looks like there aren’t any courses associated with this account. Visit the web to create a course today.", bundle: .core)
            )
                .frame(minWidth: size.width, minHeight: size.height)
        case .error:
            ZStack {
                Text(cards.error?.localizedDescription ?? "")
                    .font(.regular16).foregroundColor(.textDanger)
                    .multilineTextAlignment(.center)
            }
                .frame(minWidth: size.width, minHeight: size.height)
        }
    }

    @ViewBuilder var groupCards: some View {
        if !groups.isEmpty {
            Section(
                header: HStack(alignment: .lastTextBaseline) {
                    Text("Groups", bundle: .core)
                        .font(.heavy24).foregroundColor(.textDarkest)
                    Spacer()
                }
                    .padding(.top, 16).padding(.bottom, 8)) {
                ForEach(groups.all, id: \.id) { group in
                    GroupCard(group: group)
                        // outside the GroupCard, because that isn't observing colors
                        .accentColor(Color(group.color.ensureContrast(against: .white)))
                        .padding(.bottom, 16)
                }
            }
        }
    }

    func refresh(force: Bool, onComplete: (() -> Void)? = nil) {
        refreshCards(onComplete: onComplete)
        colors.refresh(force: force)
        courses.exhaust(force: force)
        conferences.refresh(force: force)
        invitations.exhaust(force: force)
        groups.exhaust(force: force)
        notifications.exhaust(force: force)
        settings.refresh(force: force)
    }

    func refreshCards(onComplete: (() -> Void)? = nil) {
        needsRefresh = false
        cards.refresh(force: true) { _ in
            onComplete?()
            if needsRefresh { refreshCards() }
        }
    }

    func showAllCourses() {
        env.router.route(to: "/courses", from: controller)
    }
}
