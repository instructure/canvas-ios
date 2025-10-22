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
    public typealias Model = Plannable

    public struct Response: Codable, Equatable {
        static let empty = Response(calendarEvents: [], plannables: [])

        var calendarEvents: [APICalendarEvent]
        var plannables: [APIPlannable]
    }

    private static let useCaseID = PlannableUseCaseID.syllabusSummary

    private let context: Context

    internal let assignmentsRequest: GetCalendarEventsRequest
    internal let subAssignmentsRequest: GetCalendarEventsRequest
    internal let eventsRequest: GetCalendarEventsRequest
    internal let ungradedItemsRequest: GetPlannablesRequest

    private var subscription: AnyCancellable?

    public init(context: Context) {
        self.context = context

        self.assignmentsRequest = GetCalendarEventsRequest(contexts: [context], type: .assignment, allEvents: true)
        self.subAssignmentsRequest = GetCalendarEventsRequest(contexts: [context], type: .sub_assignment, allEvents: true)
        self.eventsRequest = GetCalendarEventsRequest(contexts: [context], type: .event, allEvents: true)
        self.ungradedItemsRequest = GetPlannablesRequest(
            contextCodes: [context].map(\.canvasContextID),
            filter: "all_ungraded_todo_items"
        )
    }

    public var cacheKey: String? {
        return "get-syllabus-summary-\(context.canvasContextID)"
    }

    public var scope: Scope {
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(
                key: #keyPath(Plannable.canvasContextIDRaw),
                equals: context.canvasContextID
            ),
            NSPredicate(key: #keyPath(Plannable.originUseCaseIDRaw), equals: Self.useCaseID.rawValue)
        ])

        let order = [
            NSSortDescriptor(key: #keyPath(Plannable.hasDate), ascending: false),
            NSSortDescriptor(key: #keyPath(Plannable.date), ascending: true),
            NSSortDescriptor(key: #keyPath(Plannable.title), naturally: true)
        ]

        return Scope(predicate: predicate, order: order)
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let api = environment.api
        let assignments = api.makeRequest(assignmentsRequest)
        let subAssignments = api.makeRequest(subAssignmentsRequest)
        let events = api.makeRequest(eventsRequest)
        let ungradedItems = api.makeRequest(ungradedItemsRequest)

        subscription?.cancel()
        subscription = Publishers
            .CombineLatest(
                // calendar events
                Publishers.CombineLatest3(
                    assignments.compactMap(\.body),
                    subAssignments.compactMap(\.body),
                    events.compactMap(\.body)
                )
                .map { $0.0 + $0.1 + $0.2 },

                // planner items
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
            Plannable
                .save(plannable, userId: nil, useCase: Self.useCaseID, in: client)
        }

        response?.calendarEvents.forEach { event in
            Plannable
                .save(event, userId: nil, useCase: Self.useCaseID, in: client)
        }
    }

    public func reset(context: NSManagedObjectContext) {
        let all: [Plannable] = context.fetch(scope: scope)
        context.delete(all)
    }
}
