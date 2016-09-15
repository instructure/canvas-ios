//
//  Course.swift
//  Parent
//
//  Created by Brandon Pluim on 1/10/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CoreData
//import CakeBox
import JaSON

public final class Course: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    enum DefaultView: String {
        case Feed = "feed"
        case Wiki = "wiki"
        case Modules = "modules"
        case Assignments = "assignments"
        case Syllabus = "syllabus"
    }
    
    struct Roles: OptionSetType {
        let rawValue: Int
        init(rawValue: Int) { self.rawValue = rawValue}
        
        static let Student  = Roles(rawValue: 1)
        static let Teacher  = Roles(rawValue: 2)
        static let Observer = Roles(rawValue: 4)
        static let TA       = Roles(rawValue: 8)
        static let Designer = Roles(rawValue: 16)
    }
    
    var roles: Roles {
        get {
            return Roles(rawValue: Int(rawRoles)) ?? .Student
        } set {
            rawRoles = Int64(newValue.rawValue)
        }
    }
    
    var defaultView: DefaultView {
        get {
            return DefaultView(rawValue: rawDefaultView) ?? .Feed
        } set {
            rawDefaultView = newValue.rawValue
        }
    }
}

extension Course: SynchronizedModel {
    
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let id: Int64 = try json <| "id"
        return NSPredicate(format: "%K == %@", "id", NSNumber(longLong: id))
    }
    
    public static func updateValues(model: Course, json: JSONObject) throws {
        model.id               = try json <| "id"
        model.name             = try json <| "name"
        model.code             = try json <| "course_code"
        model.isFavorite       = try json <| "is_favorite"
        model.hideFinalGrades  = try json <| "hide_final_grades"
        model.rawDefaultView   = try json <| "default_view"
        let enrollmentsJSON: [JSONObject] = try json.JSONValueForKey("enrollments")
        var roles: Roles = []
//        var grade: Grade? = nil
        for enrollmentJSON in enrollmentsJSON {
            let type: String = try enrollmentJSON.JSONValueForKey("type")
            switch type {
            case "student":
                roles.insert(.Student)
//                grade = try Grade(json: enrollmentJSON)
            case "teacher":
                roles.insert(.Teacher)
            case "observer":
                roles.insert(.Observer)
            case "ta":
                roles.insert(.TA)
            case "designer":
                roles.insert(.Designer)
            default:
                break
            }
        }
        model.roles = roles
    }
}

import ReactiveCocoa
//import ThreeLegit

extension Course {
    public static func getCoursesByUser(session: Session, userID: Int64) throws -> SignalProducer<JSONObject, NSError> {
        let request = try session.GET("/api/v1/users/\(userID)/courses", parameters: ["include": ["total_scores", "favorites"]])
        
        return session.URLSession.paginatedJSONSignalProducer(request)
    }
}
