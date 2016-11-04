//
//  Enrollment.swift
//  Peeps
//
//  Created by Derrick Hathaway on 10/12/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import Foundation
import CoreData
import SoPersistent
import TooLegit

// Groups don't technically have enrollments, so for the case of groups the role may be []
public struct UserEnrollmentRoles: OptionSetType {
    public let rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue}
    
    public static let Student  = UserEnrollmentRoles(rawValue: 1)
    public static let Teacher  = UserEnrollmentRoles(rawValue: 2)
    public static let Observer = UserEnrollmentRoles(rawValue: 4)
    public static let TA       = UserEnrollmentRoles(rawValue: 8)
    public static let Designer = UserEnrollmentRoles(rawValue: 16)
}

public class UserEnrollment: NSManagedObject {
    @NSManaged internal(set) public var user: User?
    @NSManaged private var primitiveContextID: String
    
    internal(set) public var contextID: ContextID {
        get {
            willAccessValueForKey("context")
            defer { didAccessValueForKey("context") }
            return ContextID(canvasContext: primitiveContextID)!
        } set {
            willChangeValueForKey("context")
            defer { didChangeValueForKey("context") }
            primitiveContextID = newValue.canvasContextID
        }
    }
    
    @NSManaged private var primitiveRoles: NSNumber
    
    internal(set) public var roles: UserEnrollmentRoles {
        get {
            willAccessValueForKey("enrollmentType")
            defer { didAccessValueForKey("enrollmentType") }
            return UserEnrollmentRoles(rawValue: Int32(primitiveRoles.integerValue))
        } set {
            willChangeValueForKey("enrollmentType")
            defer { didChangeValueForKey("enrollmentType") }
            primitiveRoles = Int(newValue.rawValue)
        }
    }
}

import Marshal

extension UserEnrollment: SynchronizedModel {
    public static func uniquePredicateForObject(json: JSONObject) throws -> NSPredicate {
        let userID: String = try json.stringID("id")
        let enrolments: [JSONObject] = try json <| "enrollments" ?? []
        let courseID: String = try (enrolments.first).map { try $0.stringID("course_id") } ?? ""
        
        
        return NSPredicate(format: "%K == %@ && %K == %@",
            "user.id", userID,
            "contextID", ContextID(id: courseID, context: .Course).canvasContextID
        )
    }
    
    public func updateValues(json: JSONObject, inContext context: NSManagedObjectContext) throws {
        user = try context.findOne(withPredicate: try User.uniquePredicateForObject(json)) ?? User.create(inContext: context)
        try user?.updateValues(json, inContext: context)
        
        let enrollments: [JSONObject] = try json <| "enrollments" ?? []
        var roles = UserEnrollmentRoles()
        for eJSON in enrollments {
            contextID = ContextID(id: try eJSON.stringID("course_id"), context: .Course)
            let type: String = try eJSON <| "type"
            switch type {
            case "StudentEnrollment":
                roles.insert(.Student)
            case "TeacherEnrollment":
                roles.insert(.Teacher)
            case "TaEnrollment":
                roles.insert(.TA)
            case "ObserverEnrollment":
                roles.insert(.Observer)
            case "DesignerEnrollment":
                roles.insert(.Designer)
            default: break
            }
            self.roles = roles
        }
    }
}
