//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

import Marshal

public final class RubricCriterionRating: NSManagedObject {
    
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var assignmentID: String
    @NSManaged internal (set) public var comments: String
    @NSManaged internal (set) public var points: NSNumber
    @NSManaged internal (set) public var ratingDescription: String
}

extension RubricCriterionRating {
    @objc public static func uniquePredicateForObject(_ criterionID: String, assignmentID: String, json: JSONObject) throws -> NSPredicate {
        let id : String = (try json <| "id") ?? ""
        return NSPredicate(format: "%K == %@ && %K == %@ && %K.%K == %@", "id", id, "assignmentID", assignmentID, "criterion", "id", criterionID)
    }
    
    @objc public func updateValues(_ json: JSONObject, assignmentID: String, inContext context: NSManagedObjectContext) throws {
            id = (try json <| "id") ?? ""
            points = try json <| "points"
            ratingDescription = try json <| "description"
            self.assignmentID = assignmentID
    }
}
