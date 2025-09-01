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

    func refresh(ignoreCache: Bool) -> AnyPublisher<Bool, Error>
}

public final class TodoInteractorLive: TodoInteractor {
    public var todos: AnyPublisher<[TodoItem], Never> {
        todosSubject.eraseToAnyPublisher()
    }

    private let todosSubject = CurrentValueSubject<[TodoItem], Never>([])
    private let startDate: Date
    private let endDate: Date
    private let env: AppEnvironment

    private var subscriptions = Set<AnyCancellable>()

    init(startDate: Date = .now, endDate: Date = .distantFuture, env: AppEnvironment) {
        self.startDate = startDate
        self.endDate = endDate
        self.env = env
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Bool, Error> {
        ReactiveStore(useCase: GetCourses())
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
            .map { [weak self] in
                self?.todosSubject.value = $0
                return $0.isEmpty
            }
            .eraseToAnyPublisher()
    }
}

#if DEBUG

public final class TodoInteractorPreview: TodoInteractor {
    public let todos: AnyPublisher<[TodoItem], Never>

    public init(todos: [TodoItem] = []) {
        let todos: [TodoItem] = todos.isEmpty ? [.make(id: "1"), .make(id: "2")] : todos
        self.todos = Publishers.typedJust(todos)
    }

    public func refresh(ignoreCache: Bool) -> AnyPublisher<Bool, Error> {
        Publishers.typedJust(false)
    }
}

#endif
