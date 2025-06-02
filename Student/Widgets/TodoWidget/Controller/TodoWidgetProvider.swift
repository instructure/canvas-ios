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
        date: Date()
    )
    static let loggedOutModel: Self = .init(
        data: TodoModel(isLoggedIn: false),
        date: Date()
    )

    let data: TodoModel
    let date: Date
}

class TodoWidgetProvider: TimelineProvider {
    typealias Entry = TodoWidgetEntry

    private let env = AppEnvironment.shared
    private var refreshDate: Date { Date().addingTimeInterval(.widgetRefresh) }
    private var fetchSubscription: AnyCancellable?

    func placeholder(in context: TimelineProvider.Context) -> Entry { .publicPreview }

    func getSnapshot(in context: TimelineProvider.Context, completion: @escaping @Sendable (TodoWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: TimelineProvider.Context, completion: @escaping @Sendable (Timeline<TodoWidgetEntry>) -> Void) {

        if context.isPreview {
            let timeline = Timeline(entries: [placeholder(in: context)], policy: .never)
            completion(timeline)
            return
        }

        guard let session = LoginSession.mostRecent else {
            completion(Timeline(entries: [.loggedOutModel], policy: .after(refreshDate)))
            return
        }

        if fetchSubscription != nil { return }

        setupEnvironment(with: session)
        fetchSubscription = fetch(for: session)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] timeline in
                completion(timeline)
                self?.fetchSubscription = nil
            }
    }

    private func setupEnvironment(with session: LoginSession) {
        print("prepare environment")

        env.app = .student // Otherwise getPlannables never completes
        env.userDidLogin(session: session, isSilent: true)
    }

    private func fetch(for session: LoginSession) -> AnyPublisher<Timeline<TodoWidgetEntry>, Never> {
        print("fetch plannables")

        let env = env
        let colors = ReactiveStore(useCase: GetCustomColors(), environment: env)
        let courses = ReactiveStore(useCase: GetCourses(showFavorites: false, perPage: 100), environment: env)

        return Publishers.CombineLatest(
            colors.getEntities(),
            courses.getEntities(loadAllPages: true)
        )
        .flatMap { _, courses in
            let favoriteCourses = courses.filter { $0.isFavorite }
            let coursesToMap = favoriteCourses.isNotEmpty ? favoriteCourses : courses
            var contextCodesToFetch = coursesToMap.map(\.canvasContextID)

            let userContext = Core.Context(.user, id: session.userID)
            contextCodesToFetch.append(userContext.canvasContextID)

            return ReactiveStore(
                useCase: GetPlannables(
                    userID: "self",
                    startDate: Clock.now,
                    endDate: Clock.now.addDays(28),
                    contextCodes: contextCodesToFetch
                ),
                environment: env
            )
            .getEntities()
        }
        .map { plannables in
            let todoItems = plannables
                .filter {
                    $0.plannableType != .announcement && $0.plannableType != .assessment_request
                }
                .compactMap(TodoItem.init)

            let model = TodoModel(items: todoItems)
            let entry = TodoWidgetEntry(data: model, date: Clock.now)
            let refreshDate = Clock.now.addingTimeInterval(.widgetRefresh)
            return Timeline(entries: [entry], policy: .after(refreshDate))
        }
        .catch({ _ in
            let model = TodoModel(error: .fetchingDataFailure)
            let entry = TodoWidgetEntry(data: model, date: Clock.now)
            let recoveryDate = Clock.now.addingTimeInterval(.widgetRecover)
            return Just(
                Timeline(entries: [entry], policy: .after(recoveryDate))
            )
        })
        .eraseToAnyPublisher()
    }
}
