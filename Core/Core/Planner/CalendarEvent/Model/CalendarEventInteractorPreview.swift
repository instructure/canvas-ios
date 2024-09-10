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

final class CalendarEventInteractorPreview: CalendarEventInteractor {

    init() { }

    // MARK: - getCalendarEvent

    var getCalendarEventCallsCount: Int = 0
    var getCalendarEventInput: String?
    var getCalendarEventResult: Result<(event: CalendarEvent, contextColor: UIColor), Error>?
    var getCalendarEventDelay: Double?

    func getCalendarEvent(
        id: String,
        ignoreCache: Bool
    ) -> any Publisher<(event: CalendarEvent, contextColor: UIColor), Error> {
        getCalendarEventCallsCount += 1
        getCalendarEventInput = id

        if let getCalendarEventResult {
            if let getCalendarEventDelay {
                return getCalendarEventResult.publisher
                    .delay(for: RunLoop.SchedulerTimeType.Stride(getCalendarEventDelay), scheduler: RunLoop.main)
            } else {
                return getCalendarEventResult.publisher
            }
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    // MARK: - getCanManageCalendarPermission

    var getCanManageCalendarPermissionCallsCount: Int = 0
    var getCanManageCalendarPermissionInput: (context: Context, ignoreCache: Bool)?
    var getCanManageCalendarPermissionResult: Result<Bool, Error>? = .success(true)

    func getCanManageCalendarPermission(context: Context, ignoreCache: Bool) -> AnyPublisher<Bool, Error> {
        getCanManageCalendarPermissionCallsCount += 1
        getCanManageCalendarPermissionInput = (context: context, ignoreCache: ignoreCache)

        if let getCanManageCalendarPermissionResult {
            return getCanManageCalendarPermissionResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    // MARK: - createEvent

    var createEventCallsCount: Int = 0
    var createEventInput: CalendarEventRequestModel?
    var createEventResult: Result<Void, Error>? = .success

    func createEvent(model: CalendarEventRequestModel) -> AnyPublisher<Void, Error> {
        createEventCallsCount += 1
        createEventInput = model

        if let createEventResult {
            return createEventResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    // MARK: - updateEvent

    var updateEventCallsCount: Int = 0
    var updateEventInput: (id: String, model: CalendarEventRequestModel)?
    var updateEventResult: Result<Void, Error>? = .success

    func updateEvent(id: String, model: CalendarEventRequestModel) -> AnyPublisher<Void, Error> {
        updateEventCallsCount += 1
        updateEventInput = (id: id, model: model)

        if let updateEventResult {
            return updateEventResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    // MARK: - deleteEvent

    var deleteEventCallsCount: Int = 0
    var deleteEventInput: (id: String, seriesModificationType: SeriesModificationType?)?
    var deleteEventResult: Result<Void, Error>? = .success

    func deleteEvent(id: String, seriesModificationType: SeriesModificationType?) -> AnyPublisher<Void, any Error> {
        deleteEventCallsCount += 1
        deleteEventInput = (id: id, seriesModificationType: seriesModificationType)

        if let deleteEventResult {
            return deleteEventResult.publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }

    // MARK: - isRequestModelValid

    var isRequestModelValidCallsCount: Int = 0
    var isRequestModelValidInput: CalendarEventRequestModel?
    var isRequestModelValidResult: Bool = true

    func isRequestModelValid(_ model: CalendarEventRequestModel?) -> Bool {
        isRequestModelValidCallsCount += 1
        isRequestModelValidInput = model

        return isRequestModelValidResult
    }
}

#endif
