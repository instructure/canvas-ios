//
// Copyright (C) 2016-present Instructure, Inc.
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



public final class Page: NSManagedObject, LockableModel {
    
    @NSManaged internal (set) public var url: String // Unique locator for the page, but not unique across courses
    @NSManaged internal (set) public var htmlURL: String
    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var createdAt: Date
    @NSManaged internal (set) public var updatedAt: Date // Date the page was last updated
    @NSManaged internal (set) public var editingRoles: String // Roles allowed to edit page
    @NSManaged internal (set) public var body: String? // HTML body of page
    @NSManaged internal (set) public var published: Bool // Page published (true) or in draft state (false)
    @NSManaged internal (set) public var frontPage: Bool // Whether page is front page for wiki
    
    // MARK: - Course / Group ID
    
    @NSManaged var primitiveContextID: String
    public var contextID: ContextID {
        get {
            return ContextID(canvasContext: primitiveContextID)!
        } set {
            primitiveContextID = newValue.canvasContextID
        }
    }
    
    // MARK: - Last Editor
    
    @NSManaged internal (set) public var lastEditedByName: String? // Display Name of last editor
    @NSManaged internal (set) public var lastEditedByAvatarUrl: URL? // Avatar URL of last editor
    
    // MARK: - Locking
    
    @NSManaged public var lockedForUser: Bool
    @NSManaged public var lockExplanation: String? // Explanation of why page is locked for user
    @NSManaged public var canView: Bool
}

import Marshal


extension Page: SynchronizedModel {
    
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let url: String = try json <| "html_url"
        return NSPredicate(format: "%K == %@", "htmlURL", url)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        url             = try json <| "url"
        htmlURL         = try json <| "html_url"
        title           = try json <| "title"
        createdAt       = try json <| "created_at"
        updatedAt       = (try json <| "updated_at") ?? createdAt
        editingRoles    = (try json <| "editing_roles") ?? ""
        
        // MARK: - Break down last editor information
        
        if let lastEditedJson: JSONObject = try json <| "last_edited_by" {
            lastEditedByName = try lastEditedJson <| "display_name"
            lastEditedByAvatarUrl = try lastEditedJson <| "avatar_image_url"
        }

        body            = (try json <| "body") ?? body // body value when calling table view
        published       = try json <| "published"
        frontPage       = try json <| "front_page"
        
        try updateLockStatus(json)
    }
}
