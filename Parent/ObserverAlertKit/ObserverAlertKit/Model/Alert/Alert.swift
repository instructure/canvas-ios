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
