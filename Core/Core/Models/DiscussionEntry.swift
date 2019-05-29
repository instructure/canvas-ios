//
// Copyright (C) 2018-present Instructure, Inc.
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

public final class DiscussionEntry: NSManagedObject, WriteableModel {
    public typealias JSON = APIDiscussionEntry

    @NSManaged public var id: String
    @NSManaged public var userID: String?
    @NSManaged public var parentID: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var message: String?
    @NSManaged public var submission: Submission?

    @discardableResult
    public static func save(_ item: APIDiscussionEntry, in context: NSManagedObjectContext) -> DiscussionEntry {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(DiscussionEntry.id), item.id.value)
        let model: DiscussionEntry = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.userID = item.user_id.value
        model.parentID = item.parent_id?.value
        model.createdAt = item.created_at
        model.updatedAt = item.updated_at
        model.message = item.message
        return model
    }
}
