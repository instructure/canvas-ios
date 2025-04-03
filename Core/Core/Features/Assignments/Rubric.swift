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

public final class CDRubricCriterion: NSManagedObject {
    public typealias JSON = APIRubricCriterion

    @NSManaged public var assignmentID: String
    @NSManaged public var criterionUseRange: Bool
    @NSManaged public var desc: String
    @NSManaged public var id: String
    @NSManaged public var ignoreForScoring: Bool
    @NSManaged public var longDesc: String
    @NSManaged public var points: Double
    @NSManaged public var ratingsRaw: NSOrderedSet?

    public var ratings: [RubricRating]? {
        get { ratingsRaw?.array as? [RubricRating] }
        set { ratingsRaw = newValue.map { NSOrderedSet(array: $0) } }
    }

    @discardableResult
    public static func save(_ item: APIRubricCriterion, assignmentID: String, in context: NSManagedObjectContext) -> CDRubricCriterion {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
            #keyPath(CDRubricCriterion.id), item.id.value,
            #keyPath(CDRubricCriterion.assignmentID), assignmentID
        )
        let model: CDRubricCriterion = context.fetch(predicate).first ?? context.insert()
        model.assignmentID = assignmentID
        model.criterionUseRange = item.criterion_use_range
        model.desc = item.description
        model.id = item.id.value
        model.ignoreForScoring = item.ignore_for_scoring == true
        model.longDesc = item.long_description ?? ""
        model.points = item.points

        if let ratings = model.ratings {
            context.delete(Array(ratings))
            model.ratings = nil
        }
        if let ratings = item.ratings {
            model.ratings = ratings.map { RubricRating.save($0, assignmentID: assignmentID, in: context) }
        }

        return model
    }
}

public final class RubricRating: NSManagedObject {
    public typealias JSON = APIRubricRating

    @NSManaged public var assignmentID: String
    @NSManaged public var desc: String
    @NSManaged public var id: String
    @NSManaged public var longDesc: String
    @NSManaged public var points: Double
    @NSManaged public var position: Int

    @discardableResult
    public static func save(_ item: APIRubricRating, assignmentID: String, in context: NSManagedObjectContext) -> RubricRating {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
            #keyPath(RubricRating.id), item.id.value,
            #keyPath(RubricRating.assignmentID), assignmentID
        )
        let model: RubricRating = context.fetch(predicate).first ?? context.insert()
        model.assignmentID = assignmentID
        model.desc = item.description
        model.id = item.id.value
        model.longDesc = item.long_description
        model.points = item.points ?? 0
        return model
    }
}

public final class RubricAssessment: NSManagedObject {
    public typealias JSON = APIRubricRating

    @NSManaged public var comments: String?
    @NSManaged public var id: String
    @NSManaged var pointsRaw: NSNumber?
    @NSManaged public var ratingID: String
    @NSManaged public var submissionID: String

    public var points: Double? {
        get { return pointsRaw?.doubleValue }
        set { pointsRaw = NSNumber(value: newValue) }
    }

    @discardableResult
    public static func save(_ item: APIRubricAssessment, in context: NSManagedObjectContext, id: String, submissionID: String) -> RubricAssessment {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
            #keyPath(RubricAssessment.submissionID), submissionID,
            #keyPath(RubricAssessment.id), id
        )
        let model: RubricAssessment = context.fetch(predicate).first ?? context.insert()
        model.comments = item.comments
        model.id = id
        model.points = item.points
        model.ratingID = item.rating_id ?? ""
        model.submissionID = submissionID
        return model
    }

    public var apiEntity: APIRubricAssessment {
        APIRubricAssessment(
            comments: comments,
            points: points,
            rating_id: ratingID
        )
    }
}
