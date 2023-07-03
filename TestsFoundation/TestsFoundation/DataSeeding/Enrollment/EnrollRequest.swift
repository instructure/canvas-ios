//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core

public enum DSEnrollmentType: String, Encodable {
    case TaEnrollment
    case TeacherEnrollment
    case StudentEnrollment
    case ObserverEnrollment
    case DesignerEnrollment
}

// https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.create
struct EnrollRequest: APIRequestable {
    public typealias Response = DSEnrollment

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(courseID: String, body: RequestedEnrollment) {
        self.path = "courses/\(courseID)/enrollments"
        self.body = Body(enrollment: body)
    }
}

extension EnrollRequest {
    public struct RequestedEnrollment: Encodable {
        let enrollment_state: EnrollmentState
        let user_id: String
        let type: DSEnrollmentType
    }

    public struct Body: Encodable {
        let enrollment: RequestedEnrollment
    }
}

struct DeleteEnrollmentRequest: APIRequestable {
    public typealias Response = DSEnrollment

    public let method = APIMethod.delete
    public let path: String
    public let task: EnrollmentDeletionTaskType?

    public init(courseID: String, enrollmentId: String, task: EnrollmentDeletionTaskType? = .deleteEnrollment) {
        self.path = "courses/\(courseID)/enrollments/\(enrollmentId)"
        self.task = task
    }
}

public enum EnrollmentDeletionTaskType: String {
    case concludeEnrollment = "conclude"
    case deleteEnrollment = "delete"
    case inactivateEnrollment = "inactivate"
    case deactivateEnrollment = "deactivate"
}
