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

public final class CDRubricRating: NSManagedObject {
    public typealias JSON = APIRubricRating

    @NSManaged public var assignmentID: String
    @NSManaged public var shortDescription: String
    @NSManaged public var id: String
    @NSManaged public var longDescription: String
    @NSManaged public var points: Double
    @NSManaged public var position: Int

    @discardableResult
    public static func save(_ item: APIRubricRating, assignmentID: String, in context: NSManagedObjectContext) -> CDRubricRating {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
            #keyPath(CDRubricRating.id), item.id.value,
            #keyPath(CDRubricRating.assignmentID), assignmentID
        )
        let model: CDRubricRating = context.fetch(predicate).first ?? context.insert()
        model.assignmentID = assignmentID
        model.shortDescription = item.description
        model.id = item.id.value
        model.longDescription = item.long_description
        model.points = item.points ?? 0
        return model
    }
}
