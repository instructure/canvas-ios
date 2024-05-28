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

public protocol CreateToDoInteractor: AnyObject {
    var calendars: CurrentValueSubject<[CalendarSelectorItem], Never> { get }
    var selectedCalendar: CurrentValueSubject<CalendarSelectorItem?, Never> { get }

    func selectCalendar(with id: String)
}

final class CreateToDoInteractorLive: CreateToDoInteractor {
    let calendars = CurrentValueSubject<[CalendarSelectorItem], Never>([])
    let selectedCalendar = CurrentValueSubject<CalendarSelectorItem?, Never>(nil)

    init() {
        // TODO: request
        calendars.send(CreateToDoInteractorPreview().calendars.value)
    }

    func selectCalendar(with id: String) {
        guard selectedCalendar.value?.id != id,
              let index = calendars.value.firstIndex(where: { $0.id == id })
        else { return }

        selectedCalendar.send(calendars.value[index])
    }
}
