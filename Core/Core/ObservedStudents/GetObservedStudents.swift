//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class GetObservedStudents: CollectionUseCase {
    public typealias Model = User

    let observerID: String

    public init(observerID: String) {
        self.observerID = observerID
    }

    public var cacheKey: String? {
        return "get-observed-students-\(observerID)"
    }

    public var scope: Scope {
        return .where(#keyPath(User.observerID), equals: observerID, orderBy: #keyPath(User.id))
    }

    public var request: GetEnrollmentsRequest {
        GetEnrollmentsRequest(
            context: .currentUser,
            includes: [.observed_users, .avatar_url],
            states: GetEnrollmentsRequest.State.allForParentObserver
            // roles: [ .observer ] // filters out some desirable observer enrolements :shrug:.
        )
    }

    public func write(response: [APIEnrollment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response = response else { return }
        for enrollment in response {
            if let u = enrollment.observed_user {
                let user = User.save(u, in: client)
                user.observerID = observerID
            }
        }
    }
}

/* Does not work with manually linked observees
class GetObservedStudent: APIUseCase {
    typealias Model = User

    var cacheKey: String? { "get-observed-student-\(studentID)" }
    var request: GetObserveeRequest { GetObserveeRequest(observeeID: studentID) }
    var scope: Scope { .where(#keyPath(User.id), equals: studentID) }
    let studentID: String

    init(studentID: String) {
        self.studentID = studentID
    }
}
*/
