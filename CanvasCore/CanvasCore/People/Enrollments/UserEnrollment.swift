//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

// Groups don't technically have enrollments, so for the case of groups the role may be []
public enum UserEnrollmentRole: String {
    case student  = "StudentEnrollment"
    case teacher  = "TeacherEnrollment"
    case observer = "TaEnrollment"
    case ta       = "ObserverEnrollment"
    case designer = "DesignerEnrollment"
    
    var order: Int16 {
        switch self {
        case .student: return 2
        case .teacher: return 0
        case .observer: return 3
        case .ta: return 1
        case .designer: return -1
        }
    }
}

open class UserEnrollment: NSManagedObject {
    @NSManaged fileprivate(set) public var id: String
    @NSManaged fileprivate(set) public var url: URL?
    @NSManaged fileprivate(set) public var user: User?
    @NSManaged fileprivate(set) public var courseID: String
    @NSManaged fileprivate(set) internal var roleOrder: Int16
    
    @NSManaged fileprivate var primitiveRole: String
    
    fileprivate(set) open var role: UserEnrollmentRole {
        get {
            willAccessValue(forKey: "role")
            defer { didAccessValue(forKey: "role") }
            return UserEnrollmentRole(rawValue: primitiveRole) ?? .student
        } set {
            willChangeValue(forKey: "role")
            defer { didChangeValue(forKey: "role") }
            primitiveRole = newValue.rawValue
        }
    }
}

import Marshal

extension UserEnrollment: SynchronizedModel {
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        
        let id: String = try json.stringID("id")
        return NSPredicate(format: "%K == %@", "id", id)
    }
    
    @objc public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        
        id = try json.stringID("id")
        courseID = try json.stringID("course_id")
        role = try json <| "role"
        roleOrder = role.order
        let urlString: String = try json <| "html_url"
        guard let url = URL(string: urlString) else {
            throw MarshalError.typeMismatchWithKey(key: "html_url", expected: URL.self, actual: type(of: urlString))
        }
        self.url = url
        
        let userJSON: JSONObject = try json <| "user"
        user = try context.findOne(withPredicate: try User.uniquePredicateForObject(userJSON)) ?? User.create(inContext: context)
        try user?.updateValues(userJSON, inContext: context)
    }
}
