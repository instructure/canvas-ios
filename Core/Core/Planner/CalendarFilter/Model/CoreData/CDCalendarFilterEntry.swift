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

public class CDCalendarFilterEntry: NSManagedObject {
    @NSManaged public var name: String
    @NSManaged public var filter: CDCalendarFilter
    @NSManaged public private(set) var rawContextID: String

    public var context: Context {
        get {
            Context(canvasContextID: rawContextID)!
        }
        set {
            rawContextID = newValue.canvasContextID
        }
    }

    public var color: Color {
        let defaultColor = Color.ash
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
}

extension CDCalendarFilterEntry: Comparable {

    public static func < (lhs: CDCalendarFilterEntry, rhs: CDCalendarFilterEntry) -> Bool {
        lhs.name < rhs.name
    }
}

extension CDCalendarFilterEntry: Identifiable {

    public var id: String { rawContextID }
}
