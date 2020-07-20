//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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




let ShortcutTabIDs: Set<String> = ["assignments", "discussions", "files", "announcements"]

public final class Tab: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var label: String
    @NSManaged internal (set) public var position: Int32
    @NSManaged internal (set) public var url: URL?
    @NSManaged internal (set) public var hidden: Bool

    @NSManaged var rawContextID: String
    fileprivate (set) public var contextID: Context {
        get {
            return Context(canvasContextID: rawContextID)!
        } set {
            rawContextID = newValue.canvasContextID
        }
    }

    @objc public var isPages: Bool {
        return id == "wiki" || id == "pages"
    }

    @objc public var isHome: Bool {
        return id == "home"
    }

    @objc public var isPage: Bool {
        return id == "wiki"
    }
}




import Marshal

private let contextIDErrorMessage = NSLocalizedString("There was an error associating a tab with a course or group.", tableName: "Localizable", bundle: .core, value: "", comment: "Error message when parsing contextID for a course or group tab")
private let contextIDFailureReason = "Could not parse context id from URL"

extension Tab: SynchronizedModel {
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let url: URL = try json <| "full_url"
        guard let context = Context(url: url) else {
            throw NSError(subdomain: "Enrollments", code: 0, sessionID: nil, apiURL: URL(string: "/api/v1/context/tabs"), title: nil, description: contextIDErrorMessage, failureReason: contextIDFailureReason)
        }

        let id: String = try json <| "id"

        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "rawContextID", context.canvasContextID)
    }

    @objc public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {

        url         = try (try json <| "url")
            ?? (try json <| "full_url")

        guard let context = url.flatMap(Context.init) else {
            throw NSError(subdomain: "Enrollments", code: 0, sessionID: nil, apiURL: URL(string: "/api/v1/context/tabs"), title: nil, description: contextIDErrorMessage, failureReason: contextIDFailureReason)
        }



        contextID   = context
        id          = try json <| "id"
        position    = try json <| "position"
        label       = try json <| "label"
        hidden      = (try json <| "hidden") ?? false
    }
}
