//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public protocol CalendarToDoInteractor: AnyObject {
    func getToDo(id: String) -> AnyPublisher<Plannable, Never>

    func createToDo(
        title: String,
        date: Date,
        calendar: CDCalendarFilterEntry?,
        details: String?
    ) -> AnyPublisher<Void, Error>

    func updateToDo(
        id: String,
        title: String,
        date: Date,
        calendar: CDCalendarFilterEntry?,
        details: String?
    ) -> AnyPublisher<Void, Error>
}

final class CalendarToDoInteractorLive: CalendarToDoInteractor {

    func getToDo(id: String) -> AnyPublisher<Plannable, Never> {
        let predicate = NSPredicate(key: #keyPath(Plannable.id), equals: id)
        let useCase = LocalUseCase<Plannable>(scope: Scope(predicate: predicate, order: []))
        return ReactiveStore(useCase: useCase)
            .getEntitiesFromDatabase(keepObservingDatabaseChanges: true)
            .compactMap { $0.first }
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
    }

    func createToDo(
        title: String,
        date: Date,
        calendar: CDCalendarFilterEntry?,
        details: String?
    ) -> AnyPublisher<Void, Error> {
        let useCase = CreatePlannerNote(
            title: title,
            details: details,
            todoDate: date,
            courseID: calendar?.context.courseId,
            courseName: calendar?.courseName
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func updateToDo(
        id: String,
        title: String,
        date: Date,
        calendar: CDCalendarFilterEntry?,
        details: String?
    ) -> AnyPublisher<Void, Error> {
        let useCase = UpdatePlannerNote(
            id: id,
            title: title,
            details: details,
            todoDate: date,
            courseID: calendar?.context.courseId,
            courseName: calendar?.courseName
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }
}
