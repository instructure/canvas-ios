//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
    @NSManaged public var position: Int

    @discardableResult
    public static func save(_ item: APIRubric, in context: NSManagedObjectContext) -> Rubric {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(Rubric.id), item.id.value, #keyPath(Rubric.assignmentID), item.assignmentID ?? "")
        let model: Rubric = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.desc = item.description
        model.longDesc = item.long_description ?? ""
        model.points = item.points
        model.criterionUseRange = item.criterion_use_range
        model.assignmentID = item.assignmentID ?? ""
        model.position = item.position ?? 0

        if let ratings = model.ratings {
            context.delete(Array(ratings))
            model.ratings = nil
        }

        if let ratings = item.ratings {
            model.ratings = Set<RubricRating>()
            for (index, var r) in ratings.enumerated() {
                r.assignmentID = item.assignmentID
                r.position = index
                let ratingModel = RubricRating.save(r, in: context)
                model.ratings?.insert(ratingModel)
            }
        }

        return model
    }
}

extension Rubric {
    public static func scope(assignmentID: String) -> Scope {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Rubric.assignmentID), assignmentID)
        let sortOrder = NSSortDescriptor(key: #keyPath(Rubric.position), ascending: true)
        let scope = Scope(predicate: predicate, order: [sortOrder])
        return scope
    }
}

public final class RubricRating: NSManagedObject, WriteableModel {
    public typealias JSON = APIRubricRating

    @NSManaged public var id: String
    @NSManaged public var desc: String
    @NSManaged public var longDesc: String
    @NSManaged public var points: Double
    @NSManaged public var assignmentID: String
    @NSManaged public var position: Int

    @discardableResult
    public static func save(_ item: APIRubricRating, in context: NSManagedObjectContext) -> RubricRating {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(RubricRating.id), item.id.value, #keyPath(RubricRating.assignmentID), item.assignmentID ?? "")

        let model: RubricRating = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.desc = item.description
        model.longDesc = item.long_description
        model.points = item.points ?? 0
        model.assignmentID = item.assignmentID ?? ""
        model.position = item.position ?? 0
        return model
    }
}

public final class RubricAssessment: NSManagedObject {
    public typealias JSON = APIRubricRating

    @NSManaged public var id: String
    @NSManaged public var submissionID: String
    @NSManaged public var comments: String?
    @NSManaged var pointsRaw: NSNumber?
    @NSManaged public var ratingID: String

    public var points: Double? {
        get { return pointsRaw?.doubleValue }
        set { pointsRaw = NSNumber(value: newValue) }
    }

    @discardableResult
    public static func save(_ item: APIRubricAssessment, in context: NSManagedObjectContext, id: String, submissionID: String) -> RubricAssessment {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@", #keyPath(RubricAssessment.submissionID), submissionID, #keyPath(RubricAssessment.id), id)

        let model: RubricAssessment = context.fetch(predicate).first ?? context.insert()
        model.id = id
        model.submissionID = submissionID
        model.comments = item.comments
        model.points = item.points
        model.ratingID = item.rating_id ?? "0"
        return model
    }
}
