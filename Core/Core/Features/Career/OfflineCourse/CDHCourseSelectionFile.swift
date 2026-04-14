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
import Foundation

public final class CDHCourseSelectionFile: NSManagedObject, SizeStringConvertible {
    @NSManaged public var id: String
    @NSManaged public var courseID: String
    @NSManaged public var name: String
    @NSManaged public var size: String
    @NSManaged public var sizeInBytes: Double
    @NSManaged public var url: URL?
    @NSManaged public var mimeClass: String
    @NSManaged public var updatedAt: Date?

    @discardableResult
    static func save(
        courseID: String,
        file: GetHCourseSelectionResponse.Content,
        isBugReport: Bool = false,
        in context: NSManagedObjectContext
    ) -> CDHCourseSelectionFile {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "%K == %@", #keyPath(CDHCourseSelectionFile.courseID), courseID),
            NSPredicate(format: "%K == %@", #keyPath(CDHCourseSelectionFile.id), file.id.defaultToEmpty)
        ])
        let dbEntity: CDHCourseSelectionFile = context.fetch(predicate).first ?? context.insert()
        dbEntity.courseID = courseID
        dbEntity.id = file.id.defaultToEmpty
        dbEntity.name = file.displayName.defaultToEmpty
        dbEntity.url = file.url
        dbEntity.sizeInBytes = bytes(from: file.size.defaultToEmpty)
        dbEntity.size = file.size.defaultToEmpty
        dbEntity.mimeClass = file.mimeClass.defaultToEmpty
        dbEntity.updatedAt = file.updatedAt
        return dbEntity
    }
}
