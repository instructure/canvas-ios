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

public protocol PlannableItem {
    var plannableID: String { get }
    var plannableType: PlannableType { get }
    var htmlURL: URL? { get }
    var context: Context? { get }
    var contextName: String? { get }
    var plannableTitle: String? { get }
    var date: Date? { get }
    var pointsPossible: Double? { get }
    var details: String? { get }
    var isHidden: Bool { get }
}

extension APIPlannable: PlannableItem {
    public var plannableID: String { plannable_id.value }
    public var plannableType: PlannableType { PlannableType(rawValue: plannable_type) ?? .other }
    public var htmlURL: URL? { html_url?.rawValue }
    public var plannableTitle: String? { self.plannable?.title }
    public var date: Date? { plannable_date }
    public var pointsPossible: Double? { self.plannable?.points_possible }
    public var details: String? { self.plannable?.details }
    public var contextName: String? { context_name }
    public var isHidden: Bool { false }

    public var context: Context? {
        if let context = contextFromContextType() {
            return context
        }
        if plannableType == .planner_note {
            // Notes have no 'context_type', but have IDs in the inner 'plannable' object
            return contextFromInnerPlannableObject()
        }
        return nil
    }

    private func contextFromContextType() -> Context? {
        guard let raw = context_type, let type = ContextType(rawValue: raw.lowercased()) else {
            return nil
        }
        return switch type {
        case .course: Context(.course, id: course_id?.rawValue)
        case .group: Context(.group, id: group_id?.rawValue)
        case .user: Context(.user, id: user_id?.rawValue)
        default: nil
        }
    }

    private func contextFromInnerPlannableObject() -> Context? {
        // order matters: 'course_id' has precedence over 'user_id'
        return Context(.course, id: self.plannable?.course_id)
            ?? Context(.user, id: self.plannable?.user_id)
    }
}

extension APICalendarEvent: PlannableItem {
    public var plannableID: String { id.value }
    public var plannableType: PlannableType {
        if case .assignment = type { return .assignment }
        return .calendar_event
    }
    public var plannableTitle: String? { title }
    public var htmlURL: URL? { html_url }
    public var context: Context? { Context(canvasContextID: context_code) }
    public var contextName: String? { nil }
    public var date: Date? { start_at }
    public var pointsPossible: Double? { assignment?.points_possible }
    public var details: String? { description }
    public var isHidden: Bool { hidden == true }
}

extension APIPlannerNote: PlannableItem {
    public var plannableID: String { id }
    public var plannableType: PlannableType { .planner_note }
    public var htmlURL: URL? { nil }

    public var context: Context? {
        if let courseID = course_id {
            return Context(.course, id: courseID)
        }
        if let userId = user_id {
            return Context(.user, id: userId)
        }
        return nil
    }

    public var contextName: String? { nil }
    public var plannableTitle: String? { title }
    public var date: Date? { todo_date }
    public var pointsPossible: Double? { nil }
    public var isHidden: Bool { false }
}

public class GetPlannables: UseCase {
    public typealias Model = Plannable
    public struct Response: Codable, Equatable {
        static let empty = Response(plannables: [], calendarEvents: [], plannerNotes: [])
        static func make(
            plannables: [APIPlannable]? = nil,
            calendarEvents: [APICalendarEvent]? = nil,
            plannerNotes: [APIPlannerNote]? = nil) -> Self {
            return Response(plannables: plannables, calendarEvents: calendarEvents, plannerNotes: plannerNotes)
        }

        let plannables: [APIPlannable]?
        let calendarEvents: [APICalendarEvent]?
        let plannerNotes: [APIPlannerNote]?
    }

    var userID: String?
    var startDate: Date
    var endDate: Date
    var contextCodes: [String]?
    var filter: String = ""

    private(set) var observerEvents = PassthroughSubject<EventsRequest, Never>()
    var subscriptions = [AnyCancellable]()

    public init(userID: String? = nil, startDate: Date, endDate: Date, contextCodes: [String]? = nil, filter: String = "") {
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
        self.contextCodes = contextCodes
        self.filter = filter

        self.setupObserverEventsSubscription()
    }

    public var cacheKey: String? {
        let codes = contextCodes?.joined(separator: ",") ?? ""
        return "get-plannables-\(userID ?? "")-\(startDate)-\(endDate)-\(filter)-\(codes)"
    }

    public var scope: Scope {
        var predicate = NSPredicate(format: "%@ <= %K AND %K < %@",
            startDate as NSDate, #keyPath(Plannable.date),
            #keyPath(Plannable.date), endDate as NSDate
        )
        if let userID = userID {
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(key: #keyPath(Plannable.userID), equals: userID),
                predicate
            ])
        }
        let order = [
            NSSortDescriptor(key: #keyPath(Plannable.date), ascending: true),
            NSSortDescriptor(key: #keyPath(Plannable.title), ascending: true, naturally: true)
        ]
        return Scope(predicate: predicate, order: order)
    }

    public func reset(context: NSManagedObjectContext) {
        let all: [Plannable] = context.fetch(scope.predicate)
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
                completionHandler(.make(calendarEvents: events, plannerNotes: notes), urlResponse, error)
            }

        default:
            let request = GetPlannablesRequest(
                userID: userID,
                startDate: startDate,
                endDate: endDate,
                contextCodes: contextCodes ?? [],
                filter: filter
            )
            environment.api.exhaust(request) { response, urlResponse, error in
                completionHandler(.make(plannables: response), urlResponse, error)
            }
        }
    }

    public func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        var items: [PlannableItem] = response?.plannables ?? []
        items.append(contentsOf: response?.calendarEvents ?? [])
        items.append(contentsOf: response?.plannerNotes ?? [])

        for item in items where item.plannableType != .announcement && !item.isHidden {
            Plannable.save(item, userID: userID, in: client)
        }
    }
}
