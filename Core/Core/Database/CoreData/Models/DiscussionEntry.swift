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

public class DiscussionEntry: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var userID: String?
    @NSManaged public var parentID: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var message: String?
    @NSManaged public var submission: Submission?
}

extension DiscussionEntry {
    func update(fromApiModel item: APIDiscussionEntry, in client: PersistenceClient) throws {
        id = item.id.value
        userID = item.user_id.value
        parentID = item.parent_id?.value
        createdAt = item.created_at
        updatedAt = item.updated_at
        message = item.message
    }
}
