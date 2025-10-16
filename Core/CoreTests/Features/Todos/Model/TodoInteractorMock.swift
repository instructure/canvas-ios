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
    var todoGroups: AnyPublisher<[TodoGroupViewModel], Never> {
        todoGroupsSubject.eraseToAnyPublisher()
    }

    let todoGroupsSubject = CurrentValueSubject<[TodoGroupViewModel], Never>([])
    var refreshCalled = false
    var refreshCallCount = 0
    var lastIgnoreCache = false
    var refreshResult: Result<Void, Error> = .success(())

    var markItemAsDoneCalled = false
    var markItemAsDoneCallCount = 0
    var lastMarkAsDoneItem: TodoItemViewModel?
    var lastMarkAsDoneDone: Bool?
    var markItemAsDoneResult: Result<Void, Error> = .success(())

    func refresh(ignoreCache: Bool) -> AnyPublisher<Void, Error> {
        refreshCalled = true
        refreshCallCount += 1
        lastIgnoreCache = ignoreCache

        switch refreshResult {
        case .success:
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }

    func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<Void, Error> {
        markItemAsDoneCalled = true
        markItemAsDoneCallCount += 1
        lastMarkAsDoneItem = item
        lastMarkAsDoneDone = done

        switch markItemAsDoneResult {
        case .success:
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        case .failure(let error):
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
