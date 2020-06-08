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
import ReactiveSwift
import Marshal
import CanvasCore

extension Student {
    enum Error {
        static let NoObserverEnrollments = 100
    }

    public static func getStudents(_ session: Session, parentID: String) throws -> SignalProducer<[JSONObject], NSError> {
        return try getEnrollments(session: session)
            .flatMap(.concat, { (enrollments) -> SignalProducer<[JSONObject], NSError> in
                if (!enrollments.contains(where: hasObserverEnrollment)) {
                    let error = NSError(domain: "com.instructure.Enrollments", code: Error.NoObserverEnrollments, userInfo: [NSLocalizedDescriptionKey: "User has no observer enrollments"])
                    return SignalProducer<[JSONObject], NSError>(error: error)
                } else {
                    return SignalProducer<[JSONObject], NSError>(value: enrollments)
                }
            })
            .map(extractStudents)
            .map(insertValue(parentID, forKey: "parent_id"))
            .map(insertValue(session.baseURL.absoluteString, forKey: "student_domain"))
    }

    private static func getEnrollments(session: Session) throws -> SignalProducer<[JSONObject], NSError> {
        let params = ["state": ["creation_pending", "active", "invited", "current_and_future", "completed"], "include": ["observed_users", "avatar_url"], "role": ["ObserverEnrollment"]]
        let request = try session.GET("/api/v1/users/self/enrollments", parameters: params)
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

        guard var observedUser: JSONObject = try? enrollment <| "observed_user" else {
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
        if let rawRole: String = try? enrollment <| "type" {
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
        guard let role = enrollment["type"] as? String else { return false }
        return role == "ObserverEnrollment"
    }
}
