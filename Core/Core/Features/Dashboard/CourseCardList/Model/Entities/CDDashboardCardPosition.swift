//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public final class CDDashboardCardPosition: NSManagedObject {

    @NSManaged public var courseCode: String
    @NSManaged public var position: Int

    @discardableResult
    public static func save(courseCode: String, position: Int, in context: NSManagedObjectContext) -> CDDashboardCardPosition {
        let model: CDDashboardCardPosition = context.first(where: \CDDashboardCardPosition.courseCode, equals: courseCode)
            ?? context.insert()

        model.courseCode = courseCode
        model.position = position

        return model
    }
}
