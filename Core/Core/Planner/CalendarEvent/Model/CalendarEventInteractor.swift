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

public protocol CalendarEventInteractor: AnyObject {
    func getCalendarEvent(
        ignoreCache: Bool
    ) -> any Publisher<(event: CalendarEvent, contextColor: UIColor), Error>
}

public class CalendarEventInteractorLive: CalendarEventInteractor {
    private let calendarEventId: String

    public init(calendarEventId: String) {
        self.calendarEventId = calendarEventId
    }

    public func getCalendarEvent(
        ignoreCache: Bool = false
    ) -> any Publisher<(event: CalendarEvent, contextColor: UIColor), Error> {
        let colorsUseCase = GetCustomColors()
        let colorsStore = ReactiveStore(useCase: colorsUseCase)
        let colorPublisher = colorsStore
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .setFailureType(to: Error.self)

        let eventUseCase = GetCalendarEvent(eventID: calendarEventId)
        let eventStore = ReactiveStore(useCase: eventUseCase)

        return Publishers.CombineLatest(
            colorPublisher,
            eventStore.getEntities(ignoreCache: ignoreCache)
        )
        .tryMap { (colors, events) in
            guard let event = events.first else {
                throw StoreError.emptyResponse
            }
            let color = colors.first { $0.canvasContextID == event.contextRaw }?.color ?? .ash
            return (event, color)
        }
    }
}
