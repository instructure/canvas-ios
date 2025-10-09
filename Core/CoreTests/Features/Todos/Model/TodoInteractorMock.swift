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

@testable import Core
import Combine

final class TodoInteractorMock: TodoInteractor {
    var todos: AnyPublisher<[TodoItem], Never> {
        todosSubject.eraseToAnyPublisher()
    }

    let todosSubject = CurrentValueSubject<[TodoItem], Never>([])
    var refreshCalled = false
    var refreshCallCount = 0
    var lastIgnoreCache = false
    var refreshResult: Result<Bool, Error> = .success(false)

    func refresh(ignoreCache: Bool) -> AnyPublisher<Bool, Error> {
        refreshCalled = true
        refreshCallCount += 1
        lastIgnoreCache = ignoreCache

        switch refreshResult {
        case .success(let isEmpty):
            return Just(isEmpty)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
