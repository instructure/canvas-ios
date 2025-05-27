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
import Combine
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

    private var startDate: Date { .now.startOfDay() }
    private var endDate: Date { startDate.addDays(28) }

    private let env = AppEnvironment.shared
    private var isLoggedIn: Bool { LoginSession.mostRecent != nil }
    private var refreshDate: Date { Date().addingTimeInterval(.widgetRefresh) }
    private var fetchSubscription: AnyCancellable?

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

        if fetchSubscription != nil {
            return
        }

        setupLastLoginCredentials()
        fetchSubscription = fetch()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeline in
                completion(timeline)
                self?.fetchSubscription = nil
            }
    }

    private func setupLastLoginCredentials() {
        guard let session = LoginSession.mostRecent else { return }
        env.app = .student // Otherwise getPlannables never completes
        env.userDidLogin(session: session)
    }

    private func fetch() -> AnyPublisher<Timeline<TodoWidgetEntry>, Never> {
        let env = env
        let startDate = startDate
        let endDate = endDate
        let refreshDate = refreshDate
        let colors = ReactiveStore(useCase: GetCustomColors(), environment: env)
        let courses = ReactiveStore(useCase: GetCourses(showFavorites: false, perPage: 100), environment: env)

        return Publishers.CombineLatest(
            colors.getEntities(),
            courses.getEntities(loadAllPages: true)
        )
        .flatMap { _, courses in
            let favoriteCourses = courses.filter { $0.isFavorite }
            let coursesToMap = favoriteCourses.isNotEmpty ? favoriteCourses : courses
            var contextCodesToFetch = coursesToMap
                .compactMap(\.id)
                .map { courseId in
                    "course_\(courseId)"
                }
            if let userId = LoginSession.mostRecent?.userID {
                contextCodesToFetch.append("user_\(userId)")
            }
            let plannablesUseCase = GetPlannables(
                userID: "self",
                startDate: startDate,
                endDate: endDate,
                contextCodes: contextCodesToFetch
            )
            let plannablesStore = ReactiveStore(
                useCase: plannablesUseCase,
                environment: env
            )

            return plannablesStore.getEntities()
        }
        .map { plannables in
            let plannableItems = plannables.filter {
                $0.plannableType != .announcement && $0.plannableType != .assessment_request
            }

            let model = TodoModel(items: plannableItems)
            let entry = TodoWidgetEntry(data: model, date: Date(), message: "Data")
            return Timeline(entries: [entry], policy: .after(refreshDate))
        }
        .replaceError(with: Timeline(entries: [], policy: .after(refreshDate)))
        .eraseToAnyPublisher()
    }
}
