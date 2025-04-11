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
