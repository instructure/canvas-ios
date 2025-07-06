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

class TodoWidgetProvider: TimelineProvider {
    typealias Entry = TodoWidgetEntry

    private let env = AppEnvironment.shared
    private var refreshDate: Date { Date().addingTimeInterval(.widgetRefresh) }
    private var fetchSubscription: AnyCancellable?

    // MARK: - TimelineProvider Protocol

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
            let refreshDate = Clock.now.addingTimeInterval(.widgetRefresh)
            completion(Timeline(entries: [.loggedOutModel], policy: .after(refreshDate)))
            return
        }

        if fetchSubscription != nil { return }

        setupEnvironment(with: session)
        /// The interactor needs to be created here, after the session is setup
        let interactor = PlannerAssembly.makeFilterInteractor(observedUserId: nil)
        let getTimeline = fetch(interactor: interactor)
        let getBrandColors = ReactiveStore(useCase: GetBrandVariables())
            .getEntities()
            .replaceError(with: [])
        fetchSubscription = Publishers.CombineLatest(getTimeline, getBrandColors)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (timeline, brandVars) in
                brandVars.first?.applyBrandTheme()
                completion(timeline)
                self?.fetchSubscription = nil
            }
    }

    // MARK: - Private

    private func setupEnvironment(with session: LoginSession) {
        env.app = .student // Otherwise getPlannables never completes
        env.userDidLogin(session: session, isSilent: true)
    }

    private func fetch(
        interactor: CalendarFilterInteractor
    ) -> AnyPublisher<Timeline<TodoWidgetEntry>, Never> {
        let env = env
        return interactor
            .load(ignoreCache: false)
            .flatMap {
                interactor.selectedContexts
                    .first()
                    .setFailureType(to: Error.self)
            }
            .flatMap { contexts in
                let contextCodes = contexts.map(\.canvasContextID)
                let start = Clock.now.startOfDay()
                let end = start.addDays(28)

                let useCase = GetPlannables(
                    startDate: start,
                    endDate: end,
                    contextCodes: contextCodes
                )

                useCase.debugName = "TodoWidgetProvider.fetch"
                useCase.debugStamp = "todo-widget"

                return ReactiveStore(
                    useCase: useCase,
                    environment: env
                )
                .getEntities()
            }
            .map { plannables in

                print("Objects fetched in TodoWidget")
                print( plannables.map({ $0.debugDesc }).joined(separator: ", ") )
                print()
                
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
            .catch { _ in
                let model = TodoModel(error: .fetchingDataFailure)
                let entry = TodoWidgetEntry(data: model, date: Clock.now)
                let recoveryDate = Clock.now.addingTimeInterval(.widgetRecover)
                return Just(
                    Timeline(entries: [entry], policy: .after(recoveryDate))
                )
            }
            .eraseToAnyPublisher()
    }
}
