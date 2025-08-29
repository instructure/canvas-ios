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
    var todos: CurrentValueSubject<[TodoItem], Error> { get }

    @discardableResult
    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error>
}

public final class TodoInteractorLive: TodoInteractor {
    public let todos = CurrentValueSubject<[TodoItem], Error>([])

    private let env: AppEnvironment
    private let startDate: Date
    private let endDate: Date

    private var refreshCancellable: AnyCancellable?

    init(env: AppEnvironment, startDate: Date = .now, endDate: Date = .distantFuture) {
        self.env = env
        self.startDate = startDate
        self.endDate = endDate
        refresh(ignoreCache: false)
    }

    @discardableResult
    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        let todosPublisher = ReactiveStore(useCase: GetCourses())
            .getEntities()
            .map {
                var contextCodes: [String] = $0.filter(\.isPublished).map(\.canvasContextID)
                if let userContextCode = Context(.user, id: self.env.currentSession?.userID)?.canvasContextID {
                    contextCodes.append(userContextCode)
                }
                return contextCodes
            }
            .flatMap { codes in
                return ReactiveStore(useCase: GetPlannables(startDate: self.startDate, endDate: self.endDate, contextCodes: codes))
                    .getEntities(ignoreCache: ignoreCache, loadAllPages: true)
                    .map { $0.compactMap(TodoItem.init) }
            }
            .share()
            .eraseToAnyPublisher()

        refreshCancellable = todosPublisher
            .subscribe(todos)

        return todosPublisher
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}

#if DEBUG

public final class TodoInteractorPreview: TodoInteractor {
    public let todos: CurrentValueSubject<[TodoItem], Error>

    public init(todos: [TodoItem] = []) {
        let todos: [TodoItem] = todos.isEmpty ? [.make(id: "1"), .make(id: "2")] : todos
        self.todos = CurrentValueSubject<[TodoItem], Error>(todos)
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        return Just<Void>(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

#endif
