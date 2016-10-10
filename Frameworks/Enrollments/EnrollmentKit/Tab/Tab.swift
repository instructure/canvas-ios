//
//  Tab.swift
//  Enrollments
//
//  Created by Derrick Hathaway on 2/9/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import CoreData
import TooLegit
import SoLazy
import SoIconic

let ShortcutTabIDs: Set<String> = ["assignments", "discussions", "files", "announcements"]

public final class Tab: NSManagedObject {
    @NSManaged private (set) public var id: String
    @NSManaged private (set) public var label: String
    @NSManaged private (set) public var position: Int32
    @NSManaged private (set) public var url: NSURL
    @NSManaged private (set) public var hidden: Bool

    @NSManaged var rawContextID: String
    private (set) public var contextID: ContextID {
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
        let bundle = NSBundle(forClass: Tab.self)
        let name = "icon_\(id)_fill_small"
        guard let icon = UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: nil) else {
            fatalError("Expected icon named: \(name)")
        }
        return icon
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



import SoPersistent
import Marshal

private let contextIDErrorMessage = NSLocalizedString("There was an error associating a tab with a course or group.", tableName: "Localizable", bundle: NSBundle(identifier: "com.instructure.EnrollmentKit")!, value: "", comment: "Error message when parsing contextID for a course or group tab")
private let contextIDFailureReason = "Could not parse context id from URL"

extension Tab: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let url: NSURL = try json <| "full_url"
        guard let context = ContextID(url: url) else {
            throw NSError(subdomain: "Enrollments", code: 0, sessionID: nil, apiURL: NSURL(string: "/api/v1/context/tabs"), title: nil, description: contextIDErrorMessage, failureReason: contextIDFailureReason)
        }

        let id: String = try json <| "id"

        return NSPredicate(format: "%K == %@ && %K == %@", "id", id, "rawContextID", context.canvasContextID)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {

        url         = try (try json <| "url")
            ?? (try json <| "full_url")

        guard let context = ContextID(url: url) else {
            throw NSError(subdomain: "Enrollments", code: 0, sessionID: nil, apiURL: NSURL(string: "/api/v1/context/tabs"), title: nil, description: contextIDErrorMessage, failureReason: contextIDFailureReason)
        }



        contextID   = context
        id          = try json <| "id"
        position    = try json <| "position"
        label       = try json <| "label"
        hidden      = try json <| "hidden" ?? false
    }
}
