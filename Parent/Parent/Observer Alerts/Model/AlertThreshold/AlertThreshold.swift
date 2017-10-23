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

public enum AlertThresholdType: String {
    case courseAnnouncement = "course_announcement"
    case institutionAnnouncement = "institution_announcement"
    case assignmentGradeHigh = "assignment_grade_high"
    case assignmentGradeLow = "assignment_grade_low"
    case assignmentMissing = "assignment_missing"
    case courseGradeHigh = "course_grade_high"
    case courseGradeLow = "course_grade_low"
    case unknown = "unknown"

    public static var validThresholdTypes: [AlertThresholdType] {
        return [
            .courseAnnouncement,
            .assignmentGradeHigh,
            .assignmentGradeLow,
            .assignmentMissing,
            .courseGradeHigh,
            .courseGradeLow
        ]
    }

    public var allowsThresholdValue: Bool {
        switch self {
        case .courseGradeLow:
            return true
        case .courseGradeHigh:
            return true
        case .assignmentMissing:
            return false
        case .assignmentGradeLow:
            return true
        case .assignmentGradeHigh:
            return true
        case .institutionAnnouncement:
            return false
        case .courseAnnouncement:
            return false
        case .unknown:
            return false
        }
    }
}

public final class AlertThreshold: NSManagedObject {

    @NSManaged internal (set) public var id: String
    @NSManaged internal (set) public var observerID: String
    @NSManaged internal (set) public var studentID: String
    @NSManaged fileprivate var primitiveType: String
    static let typeKey = "type"
    internal (set) public var type: AlertThresholdType {
        get {
            willAccessValue(forKey: AlertThreshold.typeKey)
            let val = AlertThresholdType(rawValue: primitiveType) ?? .unknown
            didAccessValue(forKey: AlertThreshold.typeKey)
            if val == .unknown { print("invalid AlertType enum value: %@", primitiveType) }
            return val
        }
        set {
            willChangeValue(forKey: AlertThreshold.typeKey)
            primitiveType = newValue.rawValue
            didChangeValue(forKey: AlertThreshold.typeKey)
        }
    }
    @NSManaged internal (set) public var threshold: String?
}

extension AlertThreshold: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json.stringID("id")
        studentID = try json.stringID("student_id")
        primitiveType = try json <| "alert_type"
        threshold = try json <| "threshold"
        observerID = try json.stringID("parent_id")
    }
}
