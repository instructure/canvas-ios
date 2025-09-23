//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public class GetSyllabusSummary: UseCase {
    public typealias Model = SyllabusSummaryItem
    public struct Response: Codable, Equatable {
        static let empty = Response(calendarEvents: [], plannables: [])

        var calendarEvents: [APICalendarEvent]
        var plannables: [APIPlannable]
    }

    private let context: Context
    private var subscription: AnyCancellable?

    public init(context: Context) {
        self.context = context
    }

    public var cacheKey: String? {
        return "get-syllabus-summary-\(context.canvasContextID)"
    }

    public var scope: Scope {
        let predicate = NSPredicate(
            key: #keyPath(SyllabusSummaryItem.canvasContextIDRaw),
            equals: context.canvasContextID
        )
        let hasDate = NSSortDescriptor(key: #keyPath(SyllabusSummaryItem.hasDate), ascending: false)
        let date = NSSortDescriptor(key: #keyPath(SyllabusSummaryItem.date), ascending: true)
        let title = NSSortDescriptor(key: #keyPath(SyllabusSummaryItem.title), naturally: true)
        return Scope(predicate: predicate, order: [hasDate, date, title])
    }

    var assignmentsRequest: GetCalendarEventsRequest {
        GetCalendarEventsRequest(contexts: [context], type: .assignment, allEvents: true)
    }

    var eventsRequest: GetCalendarEventsRequest {
        GetCalendarEventsRequest(contexts: [context], type: .event, allEvents: true)
    }

    var ungradedItemsRequest: GetPlannablesRequest {
        GetPlannablesRequest(
            contextCodes: [context].map(\.canvasContextID),
            filter: "all_ungraded_todo_items"
        )
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let api = environment.api
        let assignments = api.makeRequest(assignmentsRequest)
        let events = api.makeRequest(eventsRequest)
        let ungradedItems = api.makeRequest(ungradedItemsRequest)

        subscription?.cancel()
        subscription = Publishers
            .CombineLatest(
                Publishers.CombineLatest(
                    assignments.compactMap(\.body),
                    events.compactMap(\.body)
                )
                .map({ $0.0 + $0.1 }),
                ungradedItems.compactMap(\.body)
            )
            .map { (events, plannables) in
                Response(calendarEvents: events.filter({ $0.hidden != true }), plannables: plannables)
            }
            .sinkFailureOrValue(
                receiveFailure: { error in
                    completionHandler(nil, nil, error)
                },
                receiveValue: { response in
                    completionHandler(response, nil, nil)
                }
            )
    }

    public func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {

        response?.plannables.forEach { plannable in
            SyllabusSummaryItem.save(plannable, in: client)
        }

        response?.calendarEvents.forEach { event in
            SyllabusSummaryItem.save(event, in: client)
        }
    }
}
