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
import Foundation

// MARK: - Subscription

extension GetPlannables {

    func setupObserverEventsSubscription() {

        observerEvents
            .flatMap { [weak self] request in
                guard let self else {
                    return Just((request, EventsResponse.empty)).eraseToAnyPublisher()
                }

                return contextsPublisher(env: request.env)
                    .flatMap { contexts in
                        let calendarEvents = self.calendarEventsPublisher(env: request.env, contexts: contexts, for: .event)
                        let calendarAssignments = self.calendarEventsPublisher(env: request.env, contexts: contexts, for: .assignment)

                        let allPublisher: AnyPublisher<[ObserverEvent], EventsFailure>
                        if case .teacher = request.env.app {
                            let plannerNotes = self.plannerNotesPublisher(env: request.env, contexts: contexts)
                            allPublisher = calendarEvents.merge(with: calendarAssignments, plannerNotes).eraseToAnyPublisher()
                        } else {
                            allPublisher = calendarEvents.merge(with: calendarAssignments).eraseToAnyPublisher()
                        }

                        return allPublisher
                            .reduce([], { $0 + $1 })
                            .map { events in
                                return (request, EventsResponse(events: events, response: nil, error: nil))
                            }
                            .catch { failure in
                                return Just((
                                    request,
                                    EventsResponse(events: nil, response: failure.response, error: failure.error)
                                ))
                            }
                    }
                    .eraseToAnyPublisher()
            }
            .sink { (request: EventsRequest, response: EventsResponse) in
                request.callback(response.events, response.response, response.error)
            }
            .store(in: &subscriptions)
    }

    func getObserverEvents(env: AppEnvironment, callback: @escaping EventsRequest.Callback) {
        observerEvents.send(EventsRequest(env: env, callback: callback))
    }
}

// MARK: - Publishers

extension GetPlannables {

    private func contextsPublisher(env: AppEnvironment) -> AnyPublisher<[Context], Never> {
        if let contexts = contextCodes?.compactMap({ Context(canvasContextID: $0) }) {
            return Just(contexts).eraseToAnyPublisher()
        }

        guard let userID = userID else {
            return Just([]).eraseToAnyPublisher()
        }

        let request = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100
        )

        return Future<[Context], Never> { promise in

            env.api.exhaust(request) { response, _, _ in
                guard let courses = response else {
                    promise(.success([]))
                    return
                }

                var contexts: [Context] = []
                for course in courses {
                    let enrollments = course.enrollments ?? []
                    for enrollment in enrollments where enrollment.associated_user_id?.value == userID {
                        contexts.append(Context(.course, id: course.id.value))
                    }
                }

                promise(.success(contexts))
            }
        }
        .eraseToAnyPublisher()
    }

    private func calendarEventsPublisher(env: AppEnvironment, contexts: [Context], for type: CalendarEventType) -> Future<[ObserverEvent], EventsFailure> {

        let request = GetCalendarEventsRequest(
            contexts: contexts,
            startDate: startDate,
            endDate: endDate,
            type: type,
            include: [.submission],
            allEvents: false,
            userID: userID
        )

        return Future<[ObserverEvent], EventsFailure> { promise in

            env.api.exhaust(request) { response, urlResponse, error in

                if let events = response?.map({ ObserverEvent.calendarEvent($0) }) {
                    promise(.success(events))
                } else if let error {
                    promise(.failure(.error(error, response: urlResponse)))
                } else {
                    promise(.failure(.noData(given: urlResponse)))
                }
            }
        }
    }

    private func plannerNotesPublisher(env: AppEnvironment, contexts: [Context]) -> Future<[ObserverEvent], EventsFailure> {

        let request = GetPlannerNotesRequest(
            contexts: contexts,
            startDate: startDate,
            endDate: endDate
        )

        return Future<[ObserverEvent], EventsFailure> { promise in

            env.api.exhaust(request) { response, urlResponse, error in

                if let notes = response?.map({ ObserverEvent.plannerNote($0) }) {
                    promise(.success(notes))
                } else if let error {
                    promise(.failure(.error(error, response: urlResponse)))
                } else {
                    promise(.failure(.noData(given: urlResponse)))
                }
            }
        }
    }
}

// MARK: - Models

extension GetPlannables {

    enum ObserverEvent {
        case calendarEvent(APICalendarEvent)
        case plannerNote(APIPlannerNote)

        var event: APICalendarEvent? {
            if case .calendarEvent(let event) = self { return event }
            return nil
        }

        var note: APIPlannerNote? {
            if case .plannerNote(let note) = self { return note }
            return nil
        }
    }

    struct EventsRequest {
        typealias Callback = ([ObserverEvent]?, URLResponse?, Error?) -> Void

        let env: AppEnvironment
        let callback: Callback
    }

     private struct EventsResponse {
        static let empty = EventsResponse(events: nil, response: nil, error: nil)

        var events: [ObserverEvent]?
        let response: URLResponse?
        let error: Error?
    }

     private struct EventsFailure: Error {
        struct NoData: Error { }

        let response: URLResponse?
        let error: Error

        static func noData(given response: URLResponse?) -> EventsFailure {
            return EventsFailure(response: response, error: NoData())
        }

        static func error(_ error: Error, response: URLResponse?) -> EventsFailure {
            return EventsFailure(response: response, error: error)
        }
    }
}
