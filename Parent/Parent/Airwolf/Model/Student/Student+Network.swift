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
import ReactiveSwift
import Marshal
import CanvasCore

extension Student {
    enum Error {
        static let NoObserverEnrollments = 100
    }

    public static func getStudents(_ session: Session, parentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        return try getEnrollments(session: session)
            .flatMap(.concat, transform: { (enrollments) -> SignalProducer<[JSONObject], NSError> in
                if(!enrollments.any(hasObserverEnrollment)) {
                    let error = NSError(domain: "com.instructure.Enrollments", code: Error.NoObserverEnrollments, userInfo: [NSLocalizedDescriptionKey: "User has no observer enrollments"])
                    return SignalProducer<[JSONObject], NSError>(error: error)
                }
                else {
                    return SignalProducer<[JSONObject], NSError>(value: enrollments)
                }
            })
            .map(extractStudents)
            .map(insertValue(parentID, forKey: "parent_id"))
            .map(insertValue(session.baseURL.absoluteString, forKey: "student_domain"))
    }

    private static func getEnrollments(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let request = try session.GET("/api/v1/users/self/enrollments", parameters: ["include": ["observed_users", "avatar_url"]])
        return session.paginatedJSONSignalProducer(request)
    }

    private static func extractStudents(_ enrollments: [JSONObject]) -> [JSONObject] {
        return enrollments.map(extractStudent).filter { $0 != nil }.map { $0! }
    }

    private static func extractStudent(_ enrollment: JSONObject) -> JSONObject? {
        // Make sure role is observer
        guard let role = extractRole(enrollment), role == .ta else {
            return nil
        }

        // Make sure observed user is a student
        guard var observedUser: JSONObject = try? enrollment <| "observed_user",
            let enrollments: [JSONObject] = try? observedUser <| "enrollments",
            enrollments.map(extractRole).any({ $0 == .student })
        else {
            return nil
        }

        // Custom keys
        if let id: String = try? observedUser.stringID("id") {
            observedUser["student_id"] = id
        }
        if let name: String = try? observedUser <| "name" {
            observedUser["student_name"] = name
        }

        return observedUser
    }

    private static func extractRole(_ enrollment: JSONObject) -> UserEnrollmentRole? {
        if let rawRole: String = try? enrollment <| "role" {
            return UserEnrollmentRole(rawValue: rawRole)
        }
        return nil
    }

    private static func insertValue(_ value: Any, forKey key: String) -> ([JSONObject]) -> [JSONObject] {
        return { objects in
            return objects.map { object in
                var o = object
                o[key] = value
                return o
            }
        }
    }

    private static func hasObserverEnrollment(_ enrollment: JSONObject) -> Bool {
        guard let role = enrollment["role"] as? String else { return false }
        return role == "ObserverEnrollment"
    }
}
