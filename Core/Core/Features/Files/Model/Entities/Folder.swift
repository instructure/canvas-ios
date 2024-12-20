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
    @NSManaged public var canUpload: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var filesCount: Int
    @NSManaged public var foldersCount: Int
    @NSManaged public var forSubmissions: Bool
    @NSManaged public var path: String
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

    @NSManaged public var items: Set<FolderItem>?

    public var context: Context {
        get { Context(canvasContextID: canvasContextID) ?? .currentUser }
        set { canvasContextID = newValue.canvasContextID }
    }

    @discardableResult
    public static func save(_ item: APIFolder, in client: NSManagedObjectContext) -> Folder {
        let model: Folder = client.first(where: #keyPath(Folder.id), equals: item.id.value) ?? client.insert()
        model.canUpload = item.can_upload
        model.canvasContextID = "\(item.context_type.lowercased())_\(item.context_id)"
        model.createdAt = item.created_at
        model.filesCount = item.files_count
        model.foldersCount = item.folders_count
        model.forSubmissions = item.for_submissions
        model.hidden = item.hidden ?? false
        model.hiddenForUser = item.hidden_for_user
        model.id = item.id.value
        model.locked = item.locked
        model.lockedForUser = item.locked_for_user
        model.lockAt = item.lock_at
        model.name = item.name
        model.parentFolderID = item.parent_folder_id?.value
        model.path = item.full_name.split(separator: "/").dropFirst().joined(separator: "/")
        model.position = item.position ?? 0
        model.unlockAt = item.unlock_at
        model.updatedAt = item.updated_at
        model.items?.forEach { $0.name = item.name }
        return model
    }
}

public final class FolderItem: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var parentFolderID: String?

    @NSManaged public var file: File?
    @NSManaged public var folder: Folder?

    @discardableResult
    public static func save(_ item: APIFolder, in client: NSManagedObjectContext) -> FolderItem {
        let id = "folder-\(item.id.value)"
        let model: FolderItem = client.first(where: #keyPath(FolderItem.id), equals: id) ?? client.insert()
        model.id = id
        model.name = item.name
        model.parentFolderID = item.parent_folder_id?.value
        model.folder = Folder.save(item, in: client)
        return model
    }

    @discardableResult
    public static func save(_ item: APIFile, in client: NSManagedObjectContext) -> FolderItem {
        return save(File.save(item, in: client), in: client)
    }

    @discardableResult
    public static func save(_ file: File, in client: NSManagedObjectContext) -> FolderItem {
        let id = "file-\(file.id ?? "")"
        let model: FolderItem = client.first(where: #keyPath(FolderItem.id), equals: id) ?? client.insert()
        model.id = id
        model.name = file.displayName ?? file.filename
        model.parentFolderID = file.folderID
        model.file = file
        return model
    }
}
