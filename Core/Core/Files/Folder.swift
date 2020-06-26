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

import Foundation
import CoreData

public final class Folder: NSManagedObject, WriteableModel {
    @NSManaged var canvasContextID: String
    @NSManaged public var createdAt: Date?
    @NSManaged public var filesCount: Int
    @NSManaged public var foldersCount: Int
    @NSManaged public var forSubmissions: Bool
    @NSManaged public var fullName: String
    @NSManaged public var hidden: Bool
    @NSManaged public var hiddenForUser: Bool
    @NSManaged public var id: String
    @NSManaged public var locked: Bool
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockAt: Date?
    @NSManaged public var name: String
    @NSManaged public var parentFolderID: String?
    @NSManaged public var position: Int
    @NSManaged public var unlockAt: Date?
    @NSManaged public var updatedAt: Date?

    public var context: Context {
        get { Context(canvasContextID: canvasContextID) ?? .currentUser }
        set { canvasContextID = newValue.canvasContextID }
    }

    @discardableResult
    public static func save(_ item: APIFolder, in client: NSManagedObjectContext) -> Folder {
        let model: Folder = client.first(where: #keyPath(Folder.id), equals: item.id.value) ?? client.insert()
        model.canvasContextID = "\(item.context_type.lowercased())_\(item.context_id)"
        model.createdAt = item.created_at
        model.filesCount = item.files_count
        model.foldersCount = item.folders_count
        model.forSubmissions = item.for_submissions
        model.fullName = item.full_name
        model.hidden = item.hidden ?? false
        model.hiddenForUser = item.hidden_for_user
        model.id = item.id.value
        model.locked = item.locked
        model.lockedForUser = item.locked_for_user
        model.lockAt = item.lock_at
        model.name = item.name
        model.parentFolderID = item.parent_folder_id?.value
        model.position = item.position ?? 0
        model.unlockAt = item.unlock_at
        model.updatedAt = item.updated_at
        return model
    }
}
