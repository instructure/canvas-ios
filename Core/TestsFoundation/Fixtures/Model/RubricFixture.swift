//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
@testable import Core

extension CDRubricCriterion {
    @discardableResult
    public static func make(
        from api: APIRubricCriterion = .make(),
        assignmentID: String = "1",
        in context: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> CDRubricCriterion {
        let model = CDRubricCriterion.save(api, assignmentID: assignmentID, in: context)
        try! context.save()
        return model
    }
}

extension CDRubricRating {
    @discardableResult
    public static func make(
        from api: APIRubricRating = .make(),
        assignmentID: String = "1",
        in context: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> CDRubricRating {
        let model = CDRubricRating.save(api, assignmentID: assignmentID, in: context)
        try! context.save()
        return model
    }
}

extension RubricAssessment {
    @discardableResult
    public static func make(
        from api: APIRubricAssessment = .make(),
        id: String = "1",
        submissionID: String = "1",
        in context: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> RubricAssessment {
        let model = RubricAssessment.save(api, in: context, id: id, submissionID: submissionID)
        try! context.save()
        return model
    }
}
