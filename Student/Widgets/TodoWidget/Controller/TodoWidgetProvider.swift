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

struct TodoWidgetEntry: TimelineEntry {
    static let publicPreview: Self = .init(
        data: .make(),
        date: Date(),
        message: "Preview"
    )
    static let loggedOutModel: Self = .init(
        data: TodoModel(isLoggedIn: false),
        date: Date(),
        message: "Logged out"
    )

    let data: TodoModel
    let date: Date
    let message: String

    var refreshDate: Date { Date().addingTimeInterval(.widgetRefresh) }
}

class TodoWidgetProvider: TimelineProvider {
    typealias Entry = TodoWidgetEntry

    static let startDate: Date = .now.startOfDay()
    static let endDate: Date = startDate.addDays(28)

    private var colors: Store<GetCustomColors>?
    private var plannables: Store<GetPlannables>?
    private var courses: Store<GetCourses>?
    private var favoriteCourses: Store<GetCourses>?

    private let env = AppEnvironment.shared
    private var isLoggedIn: Bool { LoginSession.mostRecent != nil }
    private var completionCalled: Bool = false
    private var refreshDate: Date { Date().addingTimeInterval(.widgetRefresh) }

    func placeholder(in context: TimelineProvider.Context) -> Entry { .publicPreview }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping @Sendable (TodoWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping @Sendable (Timeline<TodoWidgetEntry>) -> Void) {
        if context.isPreview {
            let timeline = Timeline(entries: [placeholder(in: context)], policy: .after(refreshDate))
            completion(timeline)
            return
        }
        guard isLoggedIn else {
            completion(Timeline(entries: [.loggedOutModel], policy: .after(refreshDate)))
            return
        }
        guard !completionCalled else {
            return
        }

        setupLastLoginCredentials()
        fetchData(completion: completion)
    }

    private func setupLastLoginCredentials() {
        guard let session = LoginSession.mostRecent else { return }
        env.userDidLogin(session: session)
    }

    private func fetchData(completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        colors = env.subscribe(GetCustomColors())
        colors?.refresh { [weak self] _ in
            guard let self = self, let colors = self.colors, !colors.pending else { return }

            self.courses = self.env.subscribe(GetCourses(showFavorites: false, perPage: 100)) { [weak self] in self?.courseFetchFinished(completion: completion) }
            self.courses?.refresh()

            self.favoriteCourses = self.env.subscribe(GetCourses(showFavorites: true)) { [weak self] in self?.courseFetchFinished(completion: completion) }
            self.favoriteCourses?.refresh()
        }
    }

    private func courseFetchFinished(completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        guard
            let courses = courses, !courses.pending,
            let favoriteCourses = favoriteCourses, !favoriteCourses.pending
        else {
            return
        }

        let coursesToMap = favoriteCourses.all.isNotEmpty ? favoriteCourses.all : courses.all
        var contextCodes = coursesToMap.compactMap(\.id).map { courseId in
            return "course_\(courseId)"
        }
        if let userId = LoginSession.mostRecent?.userID {
            contextCodes.append("user_\(userId)")
        }
        plannables = env.subscribe(
            GetPlannables(
                userID: "self",
                startDate: Self.startDate,
                endDate: Self.endDate,
                contextCodes: contextCodes
            )
        ) { [weak self] in
            self?.plannableFetchFinished(completion: completion)
        }
        self.plannables?.refresh(force: true)
    }

    private func plannableFetchFinished(completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        guard let plannables = plannables, !plannables.pending else { return }

        let compactPlannables = plannables.compactMap { $0 }
        let plannableItems: [Plannable] = compactPlannables.filter {
            $0.plannableType != .announcement && $0.plannableType != .assessment_request
        }

        let model = TodoModel(items: plannableItems)
        let entry = TodoWidgetEntry(data: model, date: Date(), message: "Data")
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
        completionCalled = true
    }
}
