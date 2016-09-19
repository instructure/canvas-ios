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
        return UIImage(named: "icon_\(id)", inBundle: NSBundle(forClass: Tab.self), compatibleWithTraitCollection: nil)
            ?? UIImage(named: "icon_application", inBundle: NSBundle(forClass: Tab.self), compatibleWithTraitCollection: nil)!
    }

    public var shortcutIcon: UIImage {
        guard ShortcutTabIDs.contains(id) else { ❨╯°□°❩╯⌢"Not a valid shortcut!" }
        return UIImage(named: "icon_\(id)_fill_small", inBundle: NSBundle(forClass: Tab.self), compatibleWithTraitCollection: nil)!
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
