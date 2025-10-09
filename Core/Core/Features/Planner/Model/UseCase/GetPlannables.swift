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

    let observerEvents = PassthroughSubject<EventsRequest, Never>()
    var subscriptions = Set<AnyCancellable>()

    public init(userID: String? = nil, startDate: Date, endDate: Date, contextCodes: [String]? = nil, filter: String = "") {
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
        self.contextCodes = contextCodes
        self.filter = filter

        setupObserverEventsSubscription()
    }

    public var cacheKey: String? {
        let codes = contextCodes?.joined(separator: ",") ?? ""
        return "get-plannables-\(userID ?? "")-\(startDate)-\(endDate)-\(filter)-\(codes)"
    }

    public var scope: Scope {
        var subPredicates = [
            NSPredicate(
                format: "%@ <= %K AND %K < %@",
                startDate as NSDate, #keyPath(Plannable.date),
                #keyPath(Plannable.date), endDate as NSDate
            ),
            NSPredicate(format: "%K == nil", #keyPath(Plannable.originUseCaseIDRaw))
        ]

        if let userID = userID {
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
        // If we would send out the request without any context codes the API would return all events so we do an early exit
        if (contextCodes ?? []).isEmpty {
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
            Plannable.save(item, userId: userID, in: client)
        }

        for item in calendarEventItems where item.hidden != true {
            Plannable.save(item, userId: userID, in: client)
        }

        for item in plannerNoteItems {
            Plannable.save(item, contextName: nil, in: client)
        }
    }
}
