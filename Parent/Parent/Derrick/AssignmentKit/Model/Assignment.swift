//
//  Assignment.swift
//  Assignments
//
//  Created by Derrick Hathaway on 12/28/15.
//  Copyright © 2015 Instructure. All rights reserved.
//

import Foundation
import CoreData
//import CakeBox
import JaSON

public final class Assignment: NSManagedObject {
    
    enum Kind: String {
        case Assignment
        case Quiz
        case Discussion
        case ExternalTool
    }
    
    var activityURL: NSURL? {
        get {
            return rawActivityURL.flatMap(NSURL.init)
        } set {
            rawActivityURL = newValue?.absoluteString
        }
    }
    
    var kind: Kind {
        get {
            return Kind(rawValue: rawKind) ?? .Assignment
        } set {
            rawKind = newValue.rawValue
        }
    }
    
    class func keyPathsForValuesAffectingActivityURL() -> Set<NSObject> {
        return ["rawActivityURL"]
    }
    
    class func keyPathsForValuesAffectingKind() -> Set<NSObject> {
        return ["rawKind"]
    }
}

extension Assignment: SynchronizedModel {

    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: Int64 = try json <| "id"
        return NSPredicate(format: "%K == %@", "id", NSNumber(longLong: id))
    }
    
    public static func updateValues(model: Assignment, json: JSONObject) throws {
        model.id               = try json <| "id"
        model.name             = try json <| "name"
        model.due              = try json <| "due_at"
        let desc: String?      = try json <| "description"
        model.details          = desc ?? ""
        model.activityURL      = try json <| "html_url"
        model.courseID         = try json <| "course_id"

        let submissionTypes: [String] = try json <| "submission_types"
        let kind: Kind
        if submissionTypes == ["discussion_topic"] {
            kind = .Discussion
        } else if submissionTypes == ["online_quiz"] {
            kind = .Quiz
        } else if submissionTypes == ["external_tool"] {
            kind = .ExternalTool
        } else {
            kind = .Assignment
        }
        model.kind = kind
    }
}

import ReactiveCocoa
//import ThreeLegit

extension Assignment {
    public static func getAssignments(session: Session, courseID: Int64) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/api/v1/courses/\(courseID)/assignments", parameters: ["include": ["all_dates", "submission"]])
        
        return session.URLSession.paginatedJSONSignalProducer(request)
    }
}

