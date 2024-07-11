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

public class GetPlannables: UseCase {
    public typealias Model = Plannable
    public struct Response: Codable, Equatable {
        let plannables: [APIPlannable]?
        let calendarEvents: [APICalendarEvent]?
    }

    var userID: String?
    var startDate: Date
    var endDate: Date
    var contextCodes: [String]?
    var filter: String = ""

    public init(userID: String? = nil, startDate: Date, endDate: Date, contextCodes: [String]? = nil, filter: String = "") {
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
        self.contextCodes = contextCodes
        self.filter = filter
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
            completionHandler(.init(plannables: [], calendarEvents: []), nil, nil)
            return
        }

        if environment.app == .parent {
            getObserverCalendarEvents(env: environment) { response, urlResponse, error in
                completionHandler(Response(plannables: nil, calendarEvents: response), urlResponse, error)
            }
        } else {
            let request = GetPlannablesRequest(
                userID: userID,
                startDate: startDate,
                endDate: endDate,
                contextCodes: contextCodes ?? [],
                filter: filter
            )
            environment.api.exhaust(request) { response, urlResponse, error in
                completionHandler(Response(plannables: response, calendarEvents: nil), urlResponse, error)
            }
        }
    }

    public func write(response: Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        let items: [PlannableItem] = response?.plannables ?? response?.calendarEvents ?? []
        for item in items where item.plannableType != .announcement && !item.isHidden {
            Plannable.save(item, userID: userID, in: client)
        }
    }

    func getObserverCalendarEvents(env: AppEnvironment, callback: @escaping ([APICalendarEvent]?, URLResponse?, Error?) -> Void) {
        getObserverContextCodes(env: env) { contextCodes in
            let contexts = contextCodes.compactMap(Context.init(canvasContextID:))
            self.getCalendarEvents(env: env, contexts: contexts, type: .event) { response, urlResponse, error in
                guard let events = response, error == nil else {
                    callback(nil, urlResponse, error)
                    return
                }
                self.getCalendarEvents(env: env, contexts: contexts, type: .assignment) { response, urlResponse, error in
                    guard let assignments = response, error == nil else {
                        callback(nil, urlResponse, error)
                        return
                    }
                    callback(events + assignments, urlResponse, nil)
                }
            }
        }
    }

    func getObserverContextCodes(env: AppEnvironment, callback: @escaping ([String]) -> Void) {
        if let contextCodes = contextCodes { return callback(contextCodes) }
        guard let userID = userID else { return callback(contextCodes ?? []) }
        let request = GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100
        )
        env.api.exhaust(request) { response, _, _ in
            guard let courses = response else {
                callback([])
                return
            }
            var codes: [String] = []
            for course in courses {
                let enrollments = course.enrollments ?? []
                for enrollment in enrollments where enrollment.associated_user_id?.value == userID {
                    codes.append(Context(.course, id: course.id.value).canvasContextID)
                }
            }
            callback(codes)
        }

    }

    func getCalendarEvents(env: AppEnvironment, contexts: [Context], type: CalendarEventType = .event, callback: @escaping ([APICalendarEvent]?, URLResponse?, Error?) -> Void) {
        let request = GetCalendarEventsRequest(
            contexts: contexts,
            startDate: startDate,
            endDate: endDate,
            type: type,
            include: [.submission],
            allEvents: false,
            userID: userID
        )
        env.api.exhaust(request, callback: callback)
    }
}
