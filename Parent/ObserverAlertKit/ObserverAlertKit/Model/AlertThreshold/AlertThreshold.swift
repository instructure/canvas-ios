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

public enum AlertThresholdType: String {
    case CourseAnnouncement = "course_announcement"
    case InstitutionAnnouncement = "institution_announcement"
    case AssignmentGradeHigh = "assignment_grade_high"
    case AssignmentGradeLow = "assignment_grade_low"
    case AssignmentMissing = "assignment_missing"
    case CourseGradeHigh = "course_grade_high"
    case CourseGradeLow = "course_grade_low"
    case Unknown = "unknown"

    public static var validThresholdTypes: [AlertThresholdType] {
        return [
            .CourseAnnouncement,
            .AssignmentGradeHigh,
            .AssignmentGradeLow,
            .AssignmentMissing,
            .CourseGradeHigh,
            .CourseGradeLow
        ]
    }

    public var allowsThresholdValue: Bool {
        switch self {
        case .CourseGradeLow:
            return true
        case .CourseGradeHigh:
            return true
        case .AssignmentMissing:
            return false
        case .AssignmentGradeLow:
            return true
        case .AssignmentGradeHigh:
            return true
        case .InstitutionAnnouncement:
            return false
        case .CourseAnnouncement:
            return false
        case .Unknown:
            return false
        }
    }
}

public final class AlertThreshold: NSManagedObject {

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var observerID: String
    @NSManaged internal (set) public var studentID: String
    @NSManaged private var primitiveType: String
    static let typeKey = "type"
    internal (set) public var type: AlertThresholdType {
        get {
            willAccessValueForKey(AlertThreshold.typeKey)
            let val = AlertThresholdType(rawValue: primitiveType) ?? .Unknown
            didAccessValueForKey(AlertThreshold.typeKey)
            if val == .Unknown { print("invalid AlertType enum value: %@", primitiveType) }
            return val
        }
        set {
            willChangeValueForKey(AlertThreshold.typeKey)
            primitiveType = newValue.rawValue
            didChangeValueForKey(AlertThreshold.typeKey)
        }
    }
    @NSManaged internal (set) public var threshold: String?
}

extension AlertThreshold: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        studentID = try json.stringID("student_id")
        primitiveType = try json <| "alert_type"
        threshold = try json <| "threshold"
        observerID = try json.stringID("parent_id")
    }
}
