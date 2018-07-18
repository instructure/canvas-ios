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
    
    

import CoreData




let ShortcutTabIDs: Set<String> = ["assignments", "discussions", "files", "announcements"]

public final class Tab: NSManagedObject {
    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var label: String
    @NSManaged internal (set) public var position: Int32
    @NSManaged internal (set) public var url: URL
    @NSManaged internal (set) public var hidden: Bool

    @NSManaged var rawContextID: String
    fileprivate (set) public var contextID: ContextID {
        get {
            return ContextID(canvasContext: rawContextID)!
        } set {
            rawContextID = newValue.canvasContextID
        }
    }

    public var icon: UIImage {
        switch id {
        case "announcements":   return .icon(.announcement)
        case "application":     return .icon(.lti)
        case "assignments":     return .icon(.assignment)
        case "collaborations":  return .icon(.collaboration)
        case "conferences":     return .icon(.conference)
        case "discussions":     return .icon(.discussion)
        case "files":           return .icon(.file)
        case "grades":          return .icon(.grades)
        case "home":            return .icon(.home)
        case "link":            return .icon(.link)
        case "modules":         return .icon(.module)
        case "outcomes":        return .icon(.outcome)
        case "pages":           return .icon(.page)
        case "people":          return .icon(.people)
        case "quizzes":         return .icon(.quiz)
        case "settings":        return .icon(.settings)
        case "syllabus":        return .icon(.syllabus)
        case "tools":           return .icon(.lti)
        case "user":            return .icon(.user)
        default:                return .icon(.lti)
        }
    }

    public var shortcutIcon: UIImage {
        guard ShortcutTabIDs.contains(id) else { ❨╯°□°❩╯⌢"Not a valid shortcut!" }
        // don't add new shortcuts without telling me
        assert(ShortcutTabIDs.count == 4)
        let shortcut: Icon
        switch id {
        case "discussions":     shortcut = .discussion
        case "announcements":   shortcut = .announcement
        case "files":           shortcut = .file
        case "assignments":     shortcut = .assignment
        default: ❨╯°□°❩╯⌢"Not a valid shortcut"
        }
        return .icon(shortcut)
    }

    public var isPages: Bool {
        return id == "wiki" || id == "pages"
    }

    public var isHome: Bool {
        return id == "home"
    }

    public var isPage: Bool {
        return id == "wiki"
    }
}




import Marshal

private let contextIDErrorMessage = NSLocalizedString("There was an error associating a tab with a course or group.", tableName: "Localizable", bundle: .core, value: "", comment: "Error message when parsing contextID for a course or group tab")
private let contextIDFailureReason = "Could not parse context id from URL"

extension Tab: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let url: URL = try json <| "full_url"
        guard let context = ContextID(url: url) else {
            throw NSError(subdomain: "Enrollments", code: 0, sessionID: nil, apiURL: URL(string: "/api/v1/context/tabs"), title: nil, description: contextIDErrorMessage, failureReason: contextIDFailureReason)
        }

        let id: String = try json <| "id"

        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "rawContextID", context.canvasContextID)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {

        url         = try (try json <| "url")
            ?? (try json <| "full_url")

        guard let context = ContextID(url: url) else {
            throw NSError(subdomain: "Enrollments", code: 0, sessionID: nil, apiURL: URL(string: "/api/v1/context/tabs"), title: nil, description: contextIDErrorMessage, failureReason: contextIDFailureReason)
        }



        contextID   = context
        id          = try json <| "id"
        position    = try json <| "position"
        label       = try json <| "label"
        hidden      = (try json <| "hidden") ?? false
    }
}
