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
import UIKit

public protocol CalendarEventInteractor: AnyObject {
    typealias SeriesModificationType = APICalendarEventSeriesModificationType

    func getCalendarEvent(
        id: String,
        ignoreCache: Bool
    ) -> any Publisher<(event: CalendarEvent, contextColor: UIColor), Error>

    func getCanManageCalendarPermission(context: Context, ignoreCache: Bool) -> AnyPublisher<Bool, Error>

    func createEvent(model: CalendarEventRequestModel) -> AnyPublisher<Void, Error>

    func updateEvent(
        id: String,
        model: CalendarEventRequestModel,
        seriesModificationType: SeriesModificationType?
    ) -> AnyPublisher<Void, Error>

    func deleteEvent(id: String, seriesModificationType: SeriesModificationType?) -> AnyPublisher<Void, Error>

    func isRequestModelValid(_ model: CalendarEventRequestModel?) -> Bool
}

final class CalendarEventInteractorLive: CalendarEventInteractor {

    func getCalendarEvent(
        id: String,
        ignoreCache: Bool = false
    ) -> any Publisher<(event: CalendarEvent, contextColor: UIColor), Error> {
        let colorsUseCase = GetCustomColors()
        let colorsStore = ReactiveStore(useCase: colorsUseCase)
        let colorPublisher = colorsStore
            .getEntities(ignoreCache: ignoreCache)
            .replaceError(with: [])
            .setFailureType(to: Error.self)

        let eventUseCase = GetCalendarEvent(eventID: id)
        let eventStore = ReactiveStore(useCase: eventUseCase)
        let eventPublisher = eventStore
            .getEntities(ignoreCache: ignoreCache)

        return Publishers.CombineLatest(
            colorPublisher,
            eventPublisher
        )
        .tryMap { (colors, events) in
            guard let event = events.first else {
                throw StoreError.emptyResponse
            }
            let color = colors.first { $0.canvasContextID == event.contextRaw }?.color ?? .textDark
            return (event, color)
        }
    }

    func getCanManageCalendarPermission(context: Context, ignoreCache: Bool) -> AnyPublisher<Bool, Error> {
        let useCase = GetContextPermissions(context: context, permissions: [.manageCalendar])
        return ReactiveStore(useCase: useCase)
            .getEntities(ignoreCache: ignoreCache)
            .tryMap {
                guard let permissions = $0.first else {
                    throw StoreError.emptyResponse
                }
                return permissions.manageCalendar
            }
            .eraseToAnyPublisher()
    }

    func createEvent(model: CalendarEventRequestModel) -> AnyPublisher<Void, Error> {
        let useCase = CreateCalendarEvent(
            context_code: model.contextCode,
            title: model.title,
            description: model.details,
            start_at: model.processedStartTime,
            end_at: model.processedEndTime,
            location_name: model.location,
            location_address: model.address,
            time_zone_edited: model.timeZone,
            rrule: model.rrule
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func updateEvent(
        id: String,
        model: CalendarEventRequestModel,
        seriesModificationType: SeriesModificationType?
    ) -> AnyPublisher<Void, Error> {
        let useCase = UpdateCalendarEvent(
            id: id,
            context_code: model.contextCode,
            title: model.title,
            description: model.details,
            start_at: model.processedStartTime,
            end_at: model.processedEndTime,
            location_name: model.location,
            location_address: model.address,
            time_zone_edited: model.timeZone,
            rrule: model.rrule,
            seriesModificationType: seriesModificationType
        )
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func deleteEvent(id: String, seriesModificationType: SeriesModificationType?) -> AnyPublisher<Void, Error> {
        let useCase = DeleteCalendarEvent(id: id, seriesModificationType: seriesModificationType)
        return ReactiveStore(useCase: useCase)
            .getEntities()
            .mapToVoid()
            .eraseToAnyPublisher()
    }

    func isRequestModelValid(_ model: CalendarEventRequestModel?) -> Bool {
        model?.isValid ?? false
    }
}
