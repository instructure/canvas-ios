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

public final class AssignmentDate: NSManagedObject {

    @NSManaged public var base: Bool
    @NSManaged public var id: String?
    @NSManaged public var dueAt: Date?
    @NSManaged public var lockAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var position: Int

    @discardableResult
    public static func save(_ item: APIAssignmentDate, in context: NSManagedObjectContext, assignment: Assignment, position: Int) -> AssignmentDate {
        var obj: AssignmentDate?
        //  APIAssignmentDate can have either a base or an id
        if let base = item.base, base, let ad = assignment.allDates?.filter({ $0.base == true }).first {
            obj = ad
        } else if let id = item.id?.value, let ad = assignment.allDates?.filter({ $0.id == id }).first  {
            obj = ad
        } else {
            obj = context.insert() as AssignmentDate
        }
        obj?.base = item.base ?? false
        obj?.id = item.id?.value
        obj?.dueAt = item.due_at
        obj?.lockAt = item.lock_at
        obj?.unlockAt = item.unlock_at
        obj?.position = position
        guard let updated = obj else { fatalError("unable to create new AssignmentDate") }
        assignment.allDates?.update(with: updated)
        return updated
    }
}
