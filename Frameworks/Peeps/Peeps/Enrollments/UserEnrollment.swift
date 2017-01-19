//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import CoreData
import SoPersistent
import TooLegit

// Groups don't technically have enrollments, so for the case of groups the role may be []
public struct UserEnrollmentRoles: OptionSet {
    public let rawValue: Int32
    public init(rawValue: Int32) { self.rawValue = rawValue}
    
    public static let Student  = UserEnrollmentRoles(rawValue: 1)
    public static let Teacher  = UserEnrollmentRoles(rawValue: 2)
    public static let Observer = UserEnrollmentRoles(rawValue: 4)
    public static let TA       = UserEnrollmentRoles(rawValue: 8)
    public static let Designer = UserEnrollmentRoles(rawValue: 16)
}

open class UserEnrollment: NSManagedObject {
    @NSManaged internal(set) open var user: User?
    @NSManaged fileprivate var primitiveContextID: String
    
    internal(set) open var contextID: ContextID {
        get {
            willAccessValue(forKey: "context")
            defer { didAccessValue(forKey: "context") }
            return ContextID(canvasContext: primitiveContextID)!
        } set {
            willChangeValue(forKey: "context")
            defer { didChangeValue(forKey: "context") }
            primitiveContextID = newValue.canvasContextID
        }
    }
    
    @NSManaged fileprivate var primitiveRoles: NSNumber
    
    internal(set) open var roles: UserEnrollmentRoles {
        get {
            willAccessValue(forKey: "enrollmentType")
            defer { didAccessValue(forKey: "enrollmentType") }
            return UserEnrollmentRoles(rawValue: Int32(primitiveRoles.intValue))
        } set {
            willChangeValue(forKey: "enrollmentType")
            defer { didChangeValue(forKey: "enrollmentType") }
            primitiveRoles = NSNumber(value: Int(newValue.rawValue))
        }
    }
}

import Marshal

extension UserEnrollment: SynchronizedModel {
    public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let userID: String = try json.stringID("id")
        let enrolments: [JSONObject] = (try json <| "enrollments") ?? []
        let courseID: String = try (enrolments.first).map { try $0.stringID("course_id") } ?? ""
        
        
        return NSPredicate(format: "%K == %@ && %K == %@",
            "user.id", userID,
            "contextID", ContextID.course(withID: courseID).canvasContextID
        )
    }
    
    public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        user = try context.findOne(withPredicate: try User.uniquePredicateForObject(json)) ?? User.create(inContext: context)
        try user?.updateValues(json, inContext: context)
        
        let enrollments: [JSONObject] = (try json <| "enrollments") ?? []
        var roles = UserEnrollmentRoles()
        for eJSON in enrollments {
            contextID = ContextID.course(withID: try eJSON.stringID("course_id"))
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
