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
import JaSON

public protocol AlertProtocol {
    var id: Int64 { get }
    var observerID: Int64 { get }
    var studentID: Int64 { get }
    var courseID: Int64 { get }
    var thresholdID: Int64 { get }
    var type: Alert.AlertType { get }
    var title: String { get }
    var read: Bool { get }
    var dismissed: Bool { get }
    var actionDate: NSDate? { get }
    var assetPath: String { get }
}

public final class Alert: NSManagedObject, AlertProtocol {
    
    public enum AlertType: String {
        case CourseAnnouncement = "course_announcement"
        case InstitutionAnnouncement = "institution_announcement"
        case AssignmentGradeHigh = "assignment_grade_high"
        case AssignmentGradeLow = "assignment_grade_low"
        case AssignmentMissing = "assignment_missing"
        case CourseGradeHigh = "course_grade_high"
        case CourseGradeLow = "course_grade_low"
        case Unknown = "unknown"
    }
    
    @NSManaged public var id: Int64
    @NSManaged public var observerID: Int64
    @NSManaged public var studentID: Int64
    @NSManaged public var courseID: Int64
    @NSManaged public var thresholdID: Int64
    
    @NSManaged private var primitiveType: String
    static let typeKey = "type"
    public var type: AlertType {
        get {
            willAccessValueForKey(Alert.typeKey)
            let val = AlertType(rawValue: primitiveType) ?? .Unknown
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
    
    @NSManaged public var title: String
    @NSManaged public var read: Bool
    @NSManaged public var dismissed: Bool
    @NSManaged public var actionDate: NSDate?
    @NSManaged public var assetPath: String
}

extension Alert: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: Int64 = try json <| "id"
        return NSPredicate(format: "%K == %@", "id", NSNumber(longLong: id))
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id = try json <| "id"
        observerID = try json <| "observer_id"
        studentID = try json <| "student_id"
        courseID = try json <| "course_id"
        thresholdID = try json <| "alert_threshold_id"
        primitiveType = try json <| "alert_type"
        title = try json <| "title"
        read = try json <| "read"
        dismissed = try json <| "dismissed"
        actionDate = try json <| "action_date"
        assetPath = try json <| "asset_url"
    }
}

import TooLegit
import ReactiveCocoa

extension Alert {
    static func getObserveeAlerts(session: Session, observeeID: Int64) throws -> SignalProducer<JSONObjectArray, NSError> {
        let request = try session.GET("/api/v1/alerts/student/\(session.user.id)/\(observeeID)", parameters: [:])
        return session.URLSession.paginatedJSONSignalProducer(request)
    }
}