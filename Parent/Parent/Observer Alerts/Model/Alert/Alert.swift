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

import Marshal
import CanvasCore

public final class Alert: NSManagedObject {

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var observerID: String
    @NSManaged internal (set) public var studentID: String
    @NSManaged internal (set) public var courseID: String?
    @NSManaged internal (set) public var thresholdID: String

    @NSManaged fileprivate var primitiveType: String
    static let typeKey = "type"
    internal (set) public var type: AlertThresholdType {
        get {
            willAccessValue(forKey: Alert.typeKey)
            let val = AlertThresholdType(rawValue: primitiveType) ?? .unknown
            didAccessValue(forKey: Alert.typeKey)
            if val == .unknown { print("invalid AlertType enum value: %@", primitiveType) }
            return val
        }
        set {
            willChangeValue(forKey: Alert.typeKey)
            primitiveType = newValue.rawValue
            didChangeValue(forKey: Alert.typeKey)
        }
    }

    @NSManaged internal (set) public var title: String
    @NSManaged internal (set) public var read: Bool
    @NSManaged internal (set) public var dismissed: Bool
    @NSManaged internal (set) public var actionDate: Date
    @NSManaged internal (set) public var assetPath: String
}

extension Alert: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        observerID = try json.stringID("parent_id")
        studentID = try json.stringID("student_id")
        courseID = try json.stringID("course_id")
        thresholdID = try json.stringID("alert_threshold_id")

        willChangeValue(forKey: Alert.typeKey)
        primitiveType = try json <| "alert_type"
        didChangeValue(forKey: Alert.typeKey)
        
        title = try json <| "title"
        read = try json <| "marked_read"
        dismissed = try json <| "dismissed"
        actionDate = try json <| "action_date"
        assetPath = try json <| "asset_url"
    }
}
