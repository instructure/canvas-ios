//
//  AlertThreshold.swift
//  ObserverAlertKit
//
//  Created by Brandon Pluim on 2/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
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

    public var description: String {
        switch self {
        case .CourseGradeLow:
            return NSLocalizedString("Course grade below", comment: "Course Grade Low On Description")
        case .CourseGradeHigh:
            return NSLocalizedString("Course grade above", comment: "Course Grade High On Description")
        case .AssignmentMissing:
            return NSLocalizedString("Assignment missing", comment: "Assignment Missing Description")
        case .AssignmentGradeLow:
            return NSLocalizedString("Assignment grade below", comment: "Assignment Grade Low On Description")
        case .AssignmentGradeHigh:
            return NSLocalizedString("Assignment grade above", comment: "Assignment Grade High On Description")
        case .InstitutionAnnouncement:
            return NSLocalizedString("Institution announcements", comment: "Institution Announcement Description")
        case .CourseAnnouncement:
            return NSLocalizedString("Course announcements", comment: "Course Announcement Description")
        case .Unknown:
            return NSLocalizedString("Unknown", comment: "Unknown T`hreshold Description")
        }
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
