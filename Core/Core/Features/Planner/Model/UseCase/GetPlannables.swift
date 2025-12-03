//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import CoreData
import Combine

public class GetPlannables: UseCase {
    public typealias Model = Plannable

    public struct Response: Codable, Equatable {
        static let empty = Response(plannables: [], calendarEvents: [], plannerNotes: [])

        var plannables: [APIPlannable]?
        var calendarEvents: [APICalendarEvent]?
        var plannerNotes: [APIPlannerNote]?
    }

    var userID: String?
    var startDate: Date
    var endDate: Date
    var contextCodes: [String]?
    var filter: String = ""
    var allowEmptyContextCodesFetch: Bool = false
    var useCaseID: PlannableUseCaseID?

    let observerEvents = PassthroughSubject<EventsRequest, Never>()
    var subscriptions = Set<AnyCancellable>()

    /// - parameters:
    ///   - useCaseID: When set, filters and tags plannables instance on saving with this use case ID for data isolation.
    public init(
        userID: String? = nil,
        startDate: Date,
        endDate: Date,
        contextCodes: [String]? = nil,
        filter: String = "",
        allowEmptyContextCodesFetch: Bool = false,
        useCaseID: PlannableUseCaseID? = nil
    ) {
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
        self.contextCodes = contextCodes
        self.filter = filter
        self.allowEmptyContextCodesFetch = allowEmptyContextCodesFetch
        self.useCaseID = useCaseID

        setupObserverEventsSubscription()
    }

    public var cacheKey: String? {
        let codes = contextCodes?.joined(separator: ",") ?? ""
        let useCaseIDString = useCaseID?.rawValue ?? "nil"
        return "get-plannables-\(userID ?? "")-\(startDate)-\(endDate)-\(filter)-\(codes)-\(useCaseIDString)"
    }

    public var scope: Scope {
        var subPredicates = [
            NSPredicate(
                format: "%@ <= %K AND %K < %@",
                startDate as NSDate, #keyPath(Plannable.date),
                #keyPath(Plannable.date), endDate as NSDate
            ),
            NSPredicate(key: #keyPath(Plannable.originUseCaseIDRaw), equals: useCaseID?.rawValue)
        ]

        if let userID {
            subPredicates.append(
                NSPredicate(key: #keyPath(Plannable.userID), equals: userID)
            )
        }

        let order = [
            NSSortDescriptor(key: #keyPath(Plannable.date), ascending: true),
            NSSortDescriptor(key: #keyPath(Plannable.title), ascending: true, naturally: true)
        ]

        return Scope(
            predicate: NSCompoundPredicate(type: .and, subpredicates: subPredicates),
            order: order
        )
    }

    public func reset(context: NSManagedObjectContext) {
        let all: [Plannable] = context.fetch(scope: scope)
        context.delete(all)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        // Only return empty if allowEmptyContextCodesFetch is false. Student To-do needs to fetch all plannables
        // without context codes so that's why the allowEmptyContextCodesFetch param was introduced.
        // Sending out the request without any context codes makes the API return all events,
        // which is only usable if we do local filtering (like in Student To-do).
        if !allowEmptyContextCodesFetch, (contextCodes ?? []).isEmpty {
            completionHandler(.empty, nil, nil)
            return
        }

        switch environment.app {
        case .parent, .teacher:

            getObserverEvents(env: environment) { response, urlResponse, error in
                let events = response?.compactMap({ $0.event })
                let notes = response?.compactMap({ $0.note })
                completionHandler(.init(calendarEvents: events, plannerNotes: notes), urlResponse, error)
            }

        case .student:
            let request = GetPlannablesRequest(
                userID: userID,
                startDate: startDate,
                endDate: endDate,
                contextCodes: contextCodes ?? [],
                filter: filter
            )
            environment.api.exhaust(request) { response, urlResponse, error in
                completionHandler(.init(plannables: response), urlResponse, error)
            }
        case .horizon:
            break
        case .none:
            break
        }
    }

    public func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        let plannableItems: [APIPlannable] = response?.plannables ?? []
        let calendarEventItems: [APICalendarEvent] = response?.calendarEvents ?? []
        let plannerNoteItems: [APIPlannerNote] = response?.plannerNotes ?? []

        for item in plannableItems where item.plannableType != .announcement {
            Plannable.save(item, userId: userID, useCase: useCaseID, in: client)
        }

        for item in calendarEventItems where item.hidden != true {
            Plannable.save(item, userId: userID, useCase: useCaseID, in: client)
        }

        for item in plannerNoteItems {
            Plannable.save(item, contextName: nil, useCase: useCaseID, in: client)
        }
    }
}
