//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Foundation

// https://canvas.instructure.com/doc/api/enrollment_terms.html#method.terms.create
public struct CreateDSEnrollmentTermRequest: APIRequestable {
    public typealias Response = DSEnrollmentTerm

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body) {
        self.body = body
        self.path = "accounts/self/terms"
    }
}

extension CreateDSEnrollmentTermRequest {
    public struct RequestedDSEnrollmentTerm: Encodable {
        let name: String
        let start_at: Date
        let end_at: Date

        public init(name: String, startAt: Date, endAt: Date) {
            self.name = name
            self.start_at = startAt
            self.end_at = endAt
        }
    }

    public struct Body: Encodable {
        let enrollment_term: RequestedDSEnrollmentTerm
    }
}
