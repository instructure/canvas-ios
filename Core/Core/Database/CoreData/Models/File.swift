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

final public class File: NSManagedObject {
    @NSManaged public var id: String
    @NSManaged public var uuid: String
    @NSManaged public var folderID: String
    @NSManaged public var displayName: String
    @NSManaged public var filename: String
    @NSManaged public var contentType: String
    @NSManaged public var url: URL
    // file size in bytes
    @NSManaged public var size: Int
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var locked: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var lockAt: Date?
    @NSManaged public var hiddenForUser: Bool
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var modifiedAt: Date?
    @NSManaged public var mimeClass: String
    @NSManaged public var mediaEntryID: String?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockInfo: String?
    @NSManaged public var lockExplanation: String?
    @NSManaged public var previewURL: URL?
    @NSManaged public var localFileURL: URL?
    @NSManaged public var submission: Submission?
}

extension File: Scoped {
    public enum ScopeKeys {
        case details(String)
    }

    public static func scope(forName name: ScopeKeys) -> Scope {
        switch name {
        case let .details(id):
            return .where(#keyPath(File.id), equals: id)
        }
    }
}

extension File: WriteableModel {
    public typealias JSON = APIFile

    func update(fromApiModel item: APIFile, in client: PersistenceClient) throws {
        id = item.id.value
        uuid = item.uuid
        folderID = item.folder_id.value
        displayName = item.display_name
        filename = item.filename
        contentType = item.contentType
        url = item.url
        size = item.size
        createdAt = item.created_at
        updatedAt = item.updated_at
        unlockAt = item.unlock_at
        locked = item.locked
        hidden = item.hidden
        lockAt = item.lock_at
        hiddenForUser = item.hidden_for_user
        thumbnailURL = item.thumbnail_url
        modifiedAt = item.modified_at
        mimeClass = item.mime_class
        mediaEntryID = item.media_entry_id
        lockedForUser = item.locked_for_user
        lockInfo = item.lock_info
        lockExplanation = item.lock_explanation
        previewURL = item.preview_url
    }

    @discardableResult
    public static func save(_ item: APIFile, in client: PersistenceClient) throws -> File {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(File.id), item.id.value)
        let model: File = client.fetch(predicate).first ?? client.insert()
        model.id = item.id.value
        model.uuid = item.uuid
        model.folderID = item.folder_id.value
        model.displayName = item.display_name
        model.filename = item.filename
        model.contentType = item.contentType
        model.url = item.url
        model.size = item.size
        model.createdAt = item.created_at
        model.updatedAt = item.updated_at
        model.unlockAt = item.unlock_at
        model.locked = item.locked
        model.hidden = item.hidden
        model.lockAt = item.lock_at
        model.hiddenForUser = item.hidden_for_user
        model.thumbnailURL = item.thumbnail_url
        model.modifiedAt = item.modified_at
        model.mimeClass = item.mime_class
        model.mediaEntryID = item.media_entry_id
        model.lockedForUser = item.locked_for_user
        model.lockInfo = item.lock_info
        model.lockExplanation = item.lock_explanation
        model.previewURL = item.preview_url
        return model
    }
}
