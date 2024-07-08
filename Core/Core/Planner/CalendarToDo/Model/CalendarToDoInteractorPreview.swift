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

final class CalendarToDoInteractorPreview: CalendarToDoInteractor {

    init() { }

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
            return Empty<Void, Error>().eraseToAnyPublisher()
        }
    }
}

#endif
