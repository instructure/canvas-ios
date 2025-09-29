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

import Foundation
import Combine

public protocol TodoInteractor {
    var todos: AnyPublisher<[TodoItem], Never> { get }
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error>
}

public final class TodoInteractorLive: TodoInteractor {
    public var todos: AnyPublisher<[TodoItem], Never> {
        todosSubject.eraseToAnyPublisher()
    }

    private let todosSubject = CurrentValueSubject<[TodoItem], Never>([])
    private let env: AppEnvironment

    private var subscriptions = Set<AnyCancellable>()

    init(env: AppEnvironment) {
        self.env = env
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        let startDate = Clock.now.addDays(-28)
        let endDate = Clock.now.addDays(28)
        let currentUserID = env.currentSession?.userID

        return ReactiveStore(useCase: GetCourses(), environment: env)
            .getEntities(ignoreCache: ignoreCache)
            .map {
                var contextCodes: [String] = $0.filter(\.isPublished).map(\.canvasContextID)
                if let userContextCode = Context(.user, id: currentUserID)?.canvasContextID {
                    contextCodes.append(userContextCode)
                }
                return contextCodes
            }
            .flatMap { [env] codes in
                ReactiveStore(
                    useCase: GetPlannables(startDate: startDate, endDate: endDate, contextCodes: codes),
                    environment: env
                )
                .getEntities(ignoreCache: ignoreCache, loadAllPages: true)
                .map { $0.compactMap(TodoItem.init) }
            }
            .map { [weak todosSubject] (todos: [TodoItem]) in
                TabBarBadgeCounts.todoListCount = UInt(todos.count)
                todosSubject?.value = todos
                return ()
            }
            .eraseToAnyPublisher()
    }
}

#if DEBUG

public final class TodoInteractorPreview: TodoInteractor {
    public let todos: AnyPublisher<[TodoItem], Never>

    public init(todos: [TodoItem] = []) {
        let todos: [TodoItem] = todos.isEmpty ? [.makeShortText(id: "1"), .makeLongText(id: "2")] : todos
        self.todos = Publishers.typedJust(todos)
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        Publishers.typedJust(())
    }
}

#endif
