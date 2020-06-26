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

import Foundation
import CoreData

final public class File: NSManagedObject {
    struct User: Codable {
        let id: String
        let baseURL: URL
        let masquerader: URL?

        static func == (lhs: User, rhs: LoginSession) -> Bool {
            return lhs.baseURL == rhs.baseURL &&
                lhs.id == rhs.userID &&
                lhs.masquerader == rhs.masquerader
        }
    }

    public static var idCompare: (File, File) -> Bool = {
        return $0.id ?? "" < $1.id ?? ""
    }

    // Used for sorting new uploads keeping them in order of started
    public static func objectIDCompare(_ a: File, b: File) -> Bool {
        a.objectID.uriRepresentation().lastPathComponent < b.objectID.uriRepresentation().lastPathComponent
    }

    @NSManaged public var id: String?
    @NSManaged public var uuid: String?
    @NSManaged public var folderID: String?
    @NSManaged public var displayName: String?
    @NSManaged public var filename: String?
    @NSManaged public var contentType: String?
    @NSManaged public var url: URL?
    /// file size in bytes
    @NSManaged public var size: Int
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var unlockAt: Date?
    @NSManaged public var locked: Bool
    @NSManaged public var hidden: Bool
    @NSManaged public var lockAt: Date?
    @NSManaged public var hiddenForUser: Bool
    @NSManaged public var thumbnailURL: URL?
    @NSManaged public var modifiedAt: Date?
    @NSManaged public var mimeClass: String?
    @NSManaged public var mediaEntryID: String?
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String?
    @NSManaged public var previewURL: URL?
    @NSManaged public var localFileURL: URL?
    @NSManaged public var discussionTopic: DiscussionTopic?
    @NSManaged public var submission: Submission?
    @NSManaged public var uploadError: String?
    @NSManaged public var bytesSent: Int
    @NSManaged public var taskID: String?
    @NSManaged public private(set) var userID: String?
    @NSManaged public var contextRaw: Data?
    @NSManaged public var userRaw: Data?
    @NSManaged public var usageRights: UsageRights?

    /// Used to group together files being attached to the same content
    @NSManaged public var batchID: String?

    /// The course ID of the assignment for which this file is meant to be submitted
    ///
    /// Should only be set in the case of a submission.
    /// Set using `prepareForSubmission(courseID:assignmentID:)`
    @NSManaged public private(set) var courseID: String?

    /// The assignment ID of the assignment for which this file is meant to be submitted
    ///
    /// Should only be set in the case of a submission.
    /// Set using `prepareForSubmission(courseID:assignmentID:)`
    @NSManaged public private(set) var assignmentID: String?

    public var context: FileUploadContext? {
        get { return contextRaw.flatMap { try? JSONDecoder().decode(FileUploadContext.self, from: $0) } }
        set { contextRaw = newValue.flatMap { try? JSONEncoder().encode($0) } }
    }

    var user: User? {
        get { return userRaw.flatMap { try? JSONDecoder().decode(User.self, from: $0) } }
        set {
            userRaw = newValue.flatMap { try? JSONEncoder().encode($0) }
            userID = newValue?.id
        }
    }

    public var isUploading: Bool {
        return taskID != nil
    }

    public var isUploaded: Bool {
        return id != nil
    }

    /// Prepares file for submission, creating reference to assignment via `assignmentID`.
    public func prepareForSubmission(courseID: String, assignmentID: String) {
        self.courseID = courseID
        self.assignmentID = assignmentID
    }

    /// Marks the file as unsubmitted, removing reference to assignment.
    public func markSubmitted() {
        self.courseID = nil
        self.assignmentID = nil
        self.batchID = nil
    }

    func setUser(session: LoginSession) {
        self.user = File.User(id: session.userID, baseURL: session.baseURL, masquerader: session.masquerader)
    }
}

extension File: WriteableModel {
    public typealias JSON = APIFile

    @discardableResult
    public static func save(_ item: APIFile, in context: NSManagedObjectContext) -> File {
        return save(item, to: nil, in: context)
    }

    @discardableResult
    public static func save(_ item: APIFile, to model: File?, in client: NSManagedObjectContext) -> File {
        let model = model ?? client.first(where: #keyPath(File.id), equals: item.id.value) ?? client.insert()
        model.id = item.id.value
        model.uuid = item.uuid
        model.folderID = item.folder_id.value
        model.displayName = item.display_name
        model.filename = item.filename
        model.contentType = item.contentType
        model.url = item.url?.rawValue
        model.size = item.size
        model.createdAt = item.created_at
        model.updatedAt = item.updated_at
        model.unlockAt = item.unlock_at
        model.locked = item.locked
        model.hidden = item.hidden
        model.lockAt = item.lock_at
        model.hiddenForUser = item.hidden_for_user
        model.thumbnailURL = item.thumbnail_url?.rawValue
        model.modifiedAt = item.modified_at
        model.mimeClass = item.mime_class
        model.mediaEntryID = item.media_entry_id
        model.lockedForUser = item.locked_for_user
        model.lockExplanation = item.lock_explanation
        model.previewURL = item.preview_url?.rawValue
        model.usageRights = item.usage_rights.map {
            UsageRights.save($0, to: model.usageRights, in: client)
        }
        return model
    }

    public var icon: UIImage? {
        if mimeClass == "audio" || contentType?.hasPrefix("audio/") == true {
            return UIImage.icon(.audio)
        } else if mimeClass == "doc" {
            return UIImage.icon(.document)
        } else if mimeClass == "image" || contentType?.hasPrefix("image/") == true {
            return UIImage.icon(.image)
        } else if mimeClass == "pdf" {
            return UIImage.icon(.pdf)
        } else if mimeClass == "video" || contentType?.hasPrefix("video/") == true {
            return UIImage.icon(.video)
        }
        return UIImage.icon(.document)
    }
}
