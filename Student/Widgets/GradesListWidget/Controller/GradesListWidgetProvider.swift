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

class GradesListWidgetProvider: TimelineProvider {
    typealias Entry = GradesListWidgetEntry

    private let env = AppEnvironment.shared
    private var refreshDate: Date { Date().addingTimeInterval(.widgetRefresh) }
    private var courses: Store<GetCourses>?

    // MARK: - TimelineProvider Protocol

    func placeholder(in context: TimelineProvider.Context) -> Entry { .publicPreview }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping (GradesListWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping @Sendable (Timeline<GradesListWidgetEntry>) -> Void) {

        if context.isPreview {
            let timeline = Timeline(entries: [placeholder(in: context)], policy: .never)
            completion(timeline)
            return
        }

        guard let session = LoginSession.mostRecent else {
            let refreshDate = Clock.now.addingTimeInterval(.widgetRefresh)
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

    private func fetch(_ completion: @escaping (Timeline<GradesListWidgetEntry>) -> Void) {
        courses = env.subscribe(GetCourses())
        courses?.refresh { [weak self] _ in
            guard let self = self, let allCourses = self.courses, !allCourses.pending else { return }
            let favCourses = allCourses.filter { $0.isFavorite }
            let courses = favCourses.isEmpty ? allCourses.all : favCourses
            let gradesListItems = courses.map { GradesListItem($0) }
            let gradesListModel = GradesListModel(items: gradesListItems)
            let gradesListEntries = [GradesListWidgetEntry(data: gradesListModel, date: .now)]
            let refreshDate = Clock.now.addingTimeInterval(.widgetRefresh)
            let timeline = Timeline(entries: gradesListEntries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
}
