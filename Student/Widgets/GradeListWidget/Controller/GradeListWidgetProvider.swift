//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import WidgetKit

class GradeListWidgetProvider: TimelineProvider {
    typealias Entry = GradeListWidgetEntry

    private let env = AppEnvironment.shared
    private var refreshDate: Date { Date().addingTimeInterval(.gradeListWidgetRefresh) }
    private var allCourses: Store<GetCourses>?
    private var dashboardCards: Store<GetDashboardCards>?

    // MARK: - TimelineProvider Protocol

    func placeholder(in context: TimelineProvider.Context) -> Entry { .publicPreview }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (GradeListWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping @Sendable (Timeline<GradeListWidgetEntry>) -> Void) {

        if context.isPreview {
            let timeline = Timeline(entries: [placeholder(in: context)], policy: .never)
            completion(timeline)
            return
        }

        guard let session = LoginSession.mostRecent else {
            let refreshDate = Clock.now.addingTimeInterval(.gradeListWidgetRefresh)
            completion(Timeline(entries: [.loggedOutModel], policy: .after(refreshDate)))
            return
        }

        setupEnvironment(with: session)
        fetch(completion)
    }

    // MARK: - Private

    private func setupEnvironment(with session: LoginSession) {
        env.app = .student
        env.userDidLogin(session: session, isSilent: true)
    }

    private func fetch(_ completion: @escaping @Sendable (Timeline<GradeListWidgetEntry>) -> Void) {
        dashboardCards = env.subscribe(GetDashboardCards())
        dashboardCards?.refresh { [weak self] _ in
            self?.handleFetchFinished(completion)
        }
        allCourses = env.subscribe(GetCourses())
        allCourses?.refresh { [weak self] _ in
            self?.handleFetchFinished(completion)
        }
    }

    private func handleFetchFinished(_ completion: @escaping (Timeline<GradeListWidgetEntry>) -> Void) {
        guard let dashboardCards = self.dashboardCards, !dashboardCards.pending else { return }
        guard let allCourses = self.allCourses, !allCourses.pending else { return }
        let favCourses = allCourses.filter { $0.isFavorite }
        let courses = favCourses.isEmpty ? allCourses.all : favCourses

        var orderedCourses: [Course] = []
        dashboardCards.all.forEach { card in
            if let c = courses.first(where: { $0.id == card.id }) {
                orderedCourses.append(c)
            }
        }

        let gradesListItems = orderedCourses.map { GradeListItem($0) }
        let gradesListModel = GradeListModel(items: gradesListItems as? [GradeListItem] ?? [])
        let gradesListEntries = [GradeListWidgetEntry(data: gradesListModel, date: .now)]
        let refreshDate = Clock.now.addingTimeInterval(.gradeListWidgetRefresh)
        let timeline = Timeline(entries: gradesListEntries, policy: .after(refreshDate))
        completion(timeline)
    }
}
