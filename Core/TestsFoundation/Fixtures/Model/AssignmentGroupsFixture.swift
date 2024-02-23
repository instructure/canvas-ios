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

extension AssignmentGroup {
    @discardableResult
    public static func make(
        from api: APIAssignmentGroup = .make(),
        courseID: String = "1",
        in context: NSManagedObjectContext = singleSharedTestDatabase.viewContext
    ) -> AssignmentGroup {
        let model = AssignmentGroup.save(api, courseID: courseID, in: context, updateSubmission: false, updateScoreStatistics: false)
        try! context.save()
        return model
    }
}
