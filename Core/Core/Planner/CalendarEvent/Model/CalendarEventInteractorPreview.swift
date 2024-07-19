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

class CalendarEventInteractorPreview: CalendarEventInteractor {
    private let env = PreviewEnvironment()

    func getCalendarEvent(
        id: String,
        ignoreCache: Bool
    ) -> any Publisher<(event: CalendarEvent, contextColor: UIColor), Error> {
        let result = (
            event: CalendarEvent.save(
                .make(
                    id: .init(id),
                    title: "Creative Machines and Innovative Instrumentation Conference",
                    description: "We should meet 10 minutes before the event. <a href=\"\">Click here!</a>",
                    location_name: "UCF Department of Mechanical and Aerospace Engineering",
                    location_address: "12760 Pegasus Dr\nOrlando, FL 32816"
                ),
                in: env.database.viewContext
            ),
            contextColor: UIColor.red
        )
        return Just(result)
            .setFailureType(to: Error.self)
            .delay(for: 1, scheduler: RunLoop.main)
    }

    func createEvent(_ model: CalendarEventRequestModel) -> AnyPublisher<Void, Error> {
        return Empty().eraseToAnyPublisher()
    }

    func isRequestModelValid(_ model: CalendarEventRequestModel?) -> Bool {
        true
    }
}

#endif
