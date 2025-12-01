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

import Combine
import Foundation

#if DEBUG

final class TodoInteractorPreview: TodoInteractor {
    let todoGroups: CurrentValueSubject<[TodoGroupViewModel], Never>

    init(todoGroups: [TodoGroupViewModel]? = nil) {
        if let todoGroups {
            self.todoGroups = CurrentValueSubject<[TodoGroupViewModel], Never>(todoGroups)
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today

        let todayGroup = TodoGroupViewModel(
            date: today,
            items: [
                .makeShortText(plannableId: "3")
            ]
        )
        let tomorrowGroup = TodoGroupViewModel(
            date: tomorrow,
            items: [
                .makeShortText(plannableId: "1"),
                .makeLongText(plannableId: "2")
            ]
        )
        self.todoGroups = CurrentValueSubject<[TodoGroupViewModel], Never>([todayGroup, tomorrowGroup])
    }

    func refresh(ignorePlannablesCache: Bool, ignoreCoursesCache: Bool) -> AnyPublisher<Void, Error> {
        todoGroups.send(todoGroups.value)
        return Publishers.typedJust()
    }

    func isCacheExpired() -> AnyPublisher<Bool, Never> {
        Just(false).eraseToAnyPublisher()
    }

    func markItemAsDone(_ item: TodoItemViewModel, done: Bool) -> AnyPublisher<String, Error> {
        Publishers.typedJust("preview-override-id")
    }
}

#endif
