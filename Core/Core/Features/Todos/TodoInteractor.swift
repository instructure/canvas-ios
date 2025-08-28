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
    var todosPublisher: AnyPublisher<[TodoItem], Error> { get }
}

public final class TodoInteractorLive: TodoInteractor {
    public var todosPublisher: AnyPublisher<[TodoItem], Error> {
        ReactiveStore(useCase: GetAllCourses())
            .getEntities()
            .compactMap {
                var contextCodes: [String] = $0.map { $0.canvasContextID }
                if let userContextCode = Context(.user, id: self.env.currentSession?.userID)?.canvasContextID {
                    contextCodes.append(userContextCode)
                }
                return contextCodes
            }
            .flatMap { codes in
                return ReactiveStore(useCase: GetPlannables(startDate: self.startDate, endDate: self.endDate, contextCodes: codes))
                    .getEntities(ignoreCache: true)
                    .compactMap {
                        $0.compactMap(TodoItem.init)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private let startDate: Date
    private let endDate: Date
    private let env: AppEnvironment

    init(env: AppEnvironment, startDate: Date, endDate: Date) {
        self.env = env
        self.startDate = startDate
        self.endDate = endDate
    }
}

#if DEBUG

public final class TodoInteractorMock: TodoInteractor {
    public let todosPublisher: AnyPublisher<[TodoItem], Error>

    public init(todos: [TodoItem] = []) {
        let todos: [TodoItem] = todos.isEmpty ? [
            .make(plannableID: "1"),
            .make(plannableID: "2"),
            .make(plannableID: "3"),
            .make(plannableID: "4"),
            .make(plannableID: "5"),
            .make(plannableID: "6"),
            .make(plannableID: "7"),
            .make(plannableID: "8"),
            .make(plannableID: "9"),
            .make(plannableID: "10")
        ] : todos
        self.todosPublisher = Just(todos).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

#endif
