//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import CoreData
import Foundation

public class DeclineCourseInvitation: UseCase {
    public typealias Model = Enrollment
    public typealias Response = HandleCourseInvitationRequest.Response

    public var scope: Scope {
        .where(#keyPath(Enrollment.id), equals: enrollmentID)
    }
    public let cacheKey: String? = nil
    public let ttl: TimeInterval = 0

    private let courseID: String
    private let enrollmentID: String

    public init(courseID: String, enrollmentID: String) {
        self.courseID = courseID
        self.enrollmentID = enrollmentID
    }

    public func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        let request = HandleCourseInvitationRequest(
            courseID: courseID,
            enrollmentID: enrollmentID,
            isAccepted: false
        )

        environment.api.makeRequest(request, callback: completionHandler)
    }

    public func write(response: Response?, urlResponse: URLResponse?, to context: NSManagedObjectContext) {
        guard response?.success == true else { return }

        if let enrollment: Enrollment = context.first(
            where: #keyPath(Enrollment.id),
            equals: enrollmentID
        ) {
            context.delete([enrollment])
        }
    }
}
