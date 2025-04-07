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

#if DEBUG

import Combine
import Foundation

final class CalendarToDoInteractorPreview: CalendarToDoInteractor {

    init() { }

    var getToDoCallsCount: Int = 0
    var getToDoInput: String?
    var getToDoResult: Result<Plannable, Error>?

    func getToDo(id: String) -> AnyPublisher<Plannable, Error> {
        getToDoCallsCount += 1
        getToDoInput = id

        if let getToDoResult {
            return getToDoResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    var createToDoCallsCount: Int = 0
    var createToDoInput: (title: String, date: Date, calendar: CDCalendarFilterEntry?, details: String?)?
    var createToDoResult: Result<Void, Error>? = .success

    func createToDo(
        title: String,
        date: Date,
        calendar: CDCalendarFilterEntry?,
        details: String?
    ) -> AnyPublisher<Void, Error> {
        createToDoCallsCount += 1
        createToDoInput = (title: title, date: date, calendar: calendar, details: details)

        if let createToDoResult {
            return createToDoResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    var updateToDoCallsCount: Int = 0
    // swiftlint:disable:next large_tuple
    var updateToDoInput: (id: String, title: String, date: Date, calendar: CDCalendarFilterEntry?, details: String?)?
    var updateToDoResult: Result<Void, Error>? = .success

    func updateToDo(
        id: String,
        title: String,
        date: Date,
        calendar: CDCalendarFilterEntry?,
        details: String?
    ) -> AnyPublisher<Void, Error> {
        updateToDoCallsCount += 1
        updateToDoInput = (id: id, title: title, date: date, calendar: calendar, details: details)

        if let updateToDoResult {
            return updateToDoResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    var deleteToDoCallsCount: Int = 0
    var deleteToDoInput: String?
    var deleteToDoResult: Result<Void, Error>? = .success

    func deleteToDo(id: String) -> AnyPublisher<Void, Error> {
        deleteToDoCallsCount += 1
        deleteToDoInput = id

        if let deleteToDoResult {
            return deleteToDoResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
}

#endif
