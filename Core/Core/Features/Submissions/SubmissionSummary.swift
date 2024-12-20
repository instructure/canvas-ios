//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class SubmissionSummary: NSManagedObject {
    @NSManaged public var assignmentID: String
    @NSManaged public var graded: Int
    @NSManaged public var ungraded: Int
    @NSManaged public var unsubmitted: Int

    public var submissionCount: Int { graded + ungraded + unsubmitted }

    @discardableResult
    public static func save(_ item: APISubmissionSummary, assignmentID: String, in context: NSManagedObjectContext) -> SubmissionSummary {
        let model: SubmissionSummary = context.first(where: #keyPath(SubmissionSummary.assignmentID), equals: assignmentID) ?? context.insert()
        model.assignmentID = assignmentID
        model.graded = item.graded
        model.ungraded = item.ungraded
        model.unsubmitted = item.not_submitted
        return model
    }
}
