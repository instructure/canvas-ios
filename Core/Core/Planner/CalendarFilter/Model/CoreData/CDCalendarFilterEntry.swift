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

import CoreData
import SwiftUI

public enum CDCalendarFilterPurpose: Int16 {
    case viewing = 1
    case creating = 2
    case unknown = 0

    var cacheToken: String {
        switch self {
        case .viewing: return "viewing"
        case .creating: return "creating"
        case .unknown: return "unknown"
        }
    }
}

public class CDCalendarFilterEntry: NSManagedObject {
    @NSManaged public var name: String
    /// For the observer role we have a separate list of filters for each observed student
    @NSManaged public var observedUserId: String?
    @NSManaged public private(set) var rawContextID: String // example: "course_42"
    @NSManaged public var rawPurpose: Int16

    public var context: Context {
        get {
            Context(canvasContextID: rawContextID)!
        }
        set {
            rawContextID = newValue.canvasContextID
        }
    }

    public var wrappedContext: Context? {
        Context(canvasContextID: rawContextID)
    }

    public var purpose: CDCalendarFilterPurpose {
        get {
            CDCalendarFilterPurpose(rawValue: rawPurpose) ?? .unknown
        }
        set {
            rawPurpose = newValue.rawValue
        }
    }

    public var color: Color {
        let defaultColor = Color.textDark
        let colorScope: Scope = .where(
            #keyPath(ContextColor.canvasContextID),
            equals: context.canvasContextID
        )

        guard let managedObjectContext else { return defaultColor }

        return managedObjectContext.performAndWait {
            guard let contextColor: ContextColor = managedObjectContext.fetch(scope: colorScope).first
            else {
                return defaultColor
            }

            return Color(contextColor.color)
        }
    }

    public var courseName: String? {
        context.contextType == .course ? name : nil
    }

    @discardableResult
    public static func save(
        context: Context,
        observedUserId: String? = nil,
        name: String,
        purpose: CDCalendarFilterPurpose = .unknown,
        in moContext: NSManagedObjectContext
    ) -> CDCalendarFilterEntry? {
        guard context.isValid else { return nil }

        let canvasContextID = context.canvasContextID

        let predicate = NSPredicate(key: (\CDCalendarFilterEntry.rawContextID).string, equals: canvasContextID)
            .and(NSPredicate(key: (\CDCalendarFilterEntry.observedUserId).string, equals: observedUserId))

        let model: CDCalendarFilterEntry = moContext.fetch(predicate).first ?? moContext.insert()
        model.rawContextID = canvasContextID
        model.observedUserId = observedUserId
        model.name = name
        model.purpose = purpose
        return model
    }

    @discardableResult
    public static func save(
        userId: String,
        userName: String,
        courses: [APICourse],
        groups: [APIGroup],
        observedUserId: String? = nil,
        purpose: CDCalendarFilterPurpose = .unknown,
        in moContext: NSManagedObjectContext
    ) -> [CDCalendarFilterEntry] {
        // save user filter
        let userFilters = [
            CDCalendarFilterEntry.save(
                context: .user(userId),
                observedUserId: observedUserId,
                name: userName,
                purpose: purpose,
                in: moContext
            )
        ].compactMap { $0 }

        // save course filters
        let courseFilters = courses.compactMap { course in
            CDCalendarFilterEntry.save(
                context: .course(course.id.value),
                observedUserId: observedUserId,
                name: course.name ?? "",
                purpose: purpose,
                in: moContext
            )
        }

        // save group filters
        let groupFilters = groups.compactMap { group in
            CDCalendarFilterEntry.save(
                context: .group(group.id.value),
                observedUserId: observedUserId,
                name: group.name,
                purpose: purpose,
                in: moContext
            )
        }

        return userFilters + courseFilters + groupFilters
    }
}

extension CDCalendarFilterEntry: Comparable {

    public static func < (lhs: CDCalendarFilterEntry, rhs: CDCalendarFilterEntry) -> Bool {
        let order: [ContextType] = [.user, .course, .group]

        switch (lhs.context.contextType, rhs.context.contextType) {
        case (.user, .user), (.course, .course), (.group, .group): return lhs.name < rhs.name
        case (_, _):
            let lhsPriority = order.firstIndex(of: lhs.context.contextType) ?? .max
            let rhsPriority = order.firstIndex(of: rhs.context.contextType) ?? .max
            return lhsPriority < rhsPriority
        }
    }
}

extension CDCalendarFilterEntry: Identifiable {

    public var id: String { rawContextID }
}
