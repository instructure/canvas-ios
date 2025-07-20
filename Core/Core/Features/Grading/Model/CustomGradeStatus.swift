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
import UIKit

public class CustomGradeStatus: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var courseID: String

    @discardableResult
    static public func save(_ item: APICustomGradeStatus, courseID: String, in client: NSManagedObjectContext) -> CustomGradeStatus {
        let model: CustomGradeStatus = client.first(where: #keyPath(CustomGradeStatus.id), equals: item.id) ?? client.insert()
        model.id = item.id
        model.name = item.name
        model.courseID = courseID

        let submissions: [Submission] = client.all(where: #keyPath(Submission.customGradeStatusId), equals: item.id)
        submissions.forEach { submission in
            submission.customGradeStatusName = item.name
        }

        return model
    }
}
