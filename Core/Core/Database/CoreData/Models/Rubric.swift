//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

public final class Rubric: NSManagedObject, WriteableModel {
    public typealias JSON = APIRubric

    @NSManaged public var id: String
    @NSManaged public var assignmentID: String
    @NSManaged public var desc: String
    @NSManaged public var longDesc: String
    @NSManaged public var points: Double
    @NSManaged public var criterionUseRange: Bool
    @NSManaged public var ratings: Set<RubricRating>?

    public static func save(_ item: APIRubric, in context: PersistenceClient) throws -> Rubric {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Rubric.id), item.id.value, #keyPath(Rubric.assignmentID), item.assignmentID ?? "")
        let model: Rubric = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.desc = item.description
        model.longDesc = item.long_description
        model.points = item.points
        model.criterionUseRange = item.criterion_use_range

        if let ratings = model.ratings {
            try context.delete(Array(ratings))
            model.ratings = nil
        }

        if let ratings = item.ratings {
            model.ratings = Set<RubricRating>()
            for var r in ratings {
                r.assignmentID = item.assignmentID
                let ratingModel = try RubricRating.save(r, in: context)
                model.ratings?.insert(ratingModel)
            }
        }

        return model
    }
}

public final class RubricRating: NSManagedObject, WriteableModel {
    public typealias JSON = APIRubricRating

    @NSManaged public var id: String
    @NSManaged public var desc: String
    @NSManaged public var longDesc: String
    @NSManaged public var points: Double
    @NSManaged public var assignmentID: String

    public static func save(_ item: APIRubricRating, in context: PersistenceClient) throws -> RubricRating {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(RubricRating.id), item.id.value, #keyPath(RubricRating.assignmentID), item.assignmentID ?? "")

        let model: RubricRating = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.desc = item.description
        model.longDesc = item.long_description
        model.points = item.points
        return model
    }
}
