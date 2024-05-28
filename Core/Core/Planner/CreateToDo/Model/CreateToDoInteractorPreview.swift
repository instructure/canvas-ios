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

final class CreateToDoInteractorPreview: CreateToDoInteractor {

    let calendars = CurrentValueSubject<[CalendarSelectorItem], Never>([])
    let selectedCalendar = CurrentValueSubject<CalendarSelectorItem?, Never>(nil)

    init() {
        calendars.send([
            .init(id: "101", name: "Personal Calendar", color: .red),
            .init(id: "102", name: "Course 102", color: .green),
            .init(id: "103", name: "Course 103", color: .blue),
            .init(id: "104", name: "Group 104", color: .pink),
            .init(id: "105", name: "Group 105", color: .brown),
        ])

        selectedCalendar.send(calendars.value.first)
    }

    func selectCalendar(with id: String) { }
}

#endif
