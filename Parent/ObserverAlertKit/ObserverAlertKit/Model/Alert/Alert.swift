//
//  Alert.swift
//  ObserverAlertKit
//
//  Created by Ben Kraus on 2/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import Marshal
import SoLazy

public final class Alert: NSManagedObject {

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var observerID: String
    @NSManaged internal (set) public var studentID: String
    @NSManaged internal (set) public var courseID: String?
    @NSManaged internal (set) public var thresholdID: String

    @NSManaged private var primitiveType: String
    static let typeKey = "type"
    internal (set) public var type: AlertThresholdType {
        get {
            willAccessValueForKey(Alert.typeKey)
            let val = AlertThresholdType(rawValue: primitiveType) ?? .Unknown
            didAccessValueForKey(Alert.typeKey)
            if val == .Unknown { print("invalid AlertType enum value: %@", primitiveType) }
            return val
        }
        set {
            willChangeValueForKey(Alert.typeKey)
            primitiveType = newValue.rawValue
            didChangeValueForKey(Alert.typeKey)
        }
    }

    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var read: Bool
    @NSManaged internal (set) public var dismissed: Bool
    @NSManaged internal (set) public var actionDate: NSDate
    @NSManaged internal (set) public var assetPath: String
}

extension Alert: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        observerID = try json.stringID("parent_id")
        studentID = try json.stringID("student_id")
        courseID = try json.stringID("course_id")
        thresholdID = try json.stringID("alert_threshold_id")

        willChangeValueForKey(Alert.typeKey)
        primitiveType = try json <| "alert_type"
        didChangeValueForKey(Alert.typeKey)
        
        title = try json <| "title"
        read = try json <| "marked_read"
        dismissed = try json <| "dismissed"
        actionDate = try json <| "action_date"
        assetPath = try json <| "asset_url"
    }
}
