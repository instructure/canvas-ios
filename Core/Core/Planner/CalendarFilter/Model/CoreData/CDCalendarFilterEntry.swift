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
    @NSManaged public private(set) var rawContextID: String
    @NSManaged public var rawPurpose: Int16

    public var context: Context {
        get {
            Context(canvasContextID: rawContextID)!
        }
        set {
            rawContextID = newValue.canvasContextID
        }
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
