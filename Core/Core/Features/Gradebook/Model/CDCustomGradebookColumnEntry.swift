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
import Foundation

public class CDCustomGradebookColumnEntry: NSManagedObject {

    @NSManaged public private(set) var courseId: String
    @NSManaged public private(set) var columnId: String

    @NSManaged public var userId: String
    @NSManaged public var content: String

    @discardableResult
    public static func save(
        _ item: APICustomGradebookColumnEntry,
        courseId: String,
        columnId: String,
        in moContext: NSManagedObjectContext
    ) -> CDCustomGradebookColumnEntry {

        let predicate = NSPredicate(key: (\CDCustomGradebookColumnEntry.courseId).string, equals: courseId)
            .and(NSPredicate(key: (\CDCustomGradebookColumnEntry.columnId).string, equals: columnId))
            .and(NSPredicate(key: (\CDCustomGradebookColumnEntry.userId).string, equals: item.user_id))

        let model: CDCustomGradebookColumnEntry = moContext.fetch(predicate).first ?? moContext.insert()
        model.courseId = courseId
        model.columnId = columnId
        model.userId = item.user_id
        model.content = item.content ?? ""
        return model
    }
}
