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

import Marshal
import CanvasCore

public final class Student: NSManagedObject {
    @NSManaged fileprivate (set) public var id: String
    @NSManaged fileprivate (set) public var parentID: String
    @NSManaged fileprivate (set) public var name: String
    @NSManaged fileprivate (set) public var shortName: String
    @NSManaged fileprivate (set) public var sortableName: String
    @NSManaged fileprivate (set) public var avatarURL: URL?
    @NSManaged fileprivate (set) public var domain: URL?
    @NSManaged fileprivate (set) public var pronouns: String?
}

extension Student: SynchronizedModel {
    @objc public static func uniquePredicateForObject(_ json: JSONObject) throws -> NSPredicate {
        let id: String = try json.stringID("student_id")
        return NSPredicate(format: "%K == %@", "id", id)
    }

    @objc public func updateValues(_ json: JSONObject, inContext context: NSManagedObjectContext) throws {
        id              = try json.stringID("student_id")
        parentID        = try json.stringID("parent_id")
        name            = try json <| "student_name"
        shortName       = (try json <| "short_name") ?? name
        sortableName    = (try json <| "sortable_name") ?? name
        avatarURL       = try json <| "avatar_url"
        domain          = try json <| "student_domain"
        pronouns        = try json <| "pronouns"
    }
}

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
