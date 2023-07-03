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

public class CreateDSGradingStandardsRequest: APIRequestable {
    public typealias Response = DSGradingStandard

    public let method = APIMethod.post
    public let path: String
    public let body: RequestedDSGradingStandards?

    public init(body: RequestedDSGradingStandards? = RequestedDSGradingStandards(), courseId: String) {
        self.body = body
        self.path = "courses/\(courseId)/grading_standards"
    }
}

extension CreateDSGradingStandardsRequest {
    public struct RequestedDSGradingStandards: Encodable {
        public let title: String
        public let grading_scheme_entry: [GradeEntry]
        public static let StandardGradingScheme: [GradeEntry] = [
            GradeEntry(name: "A", value: 94), GradeEntry(name: "A-", value: 90),
            GradeEntry(name: "B+", value: 87), GradeEntry(name: "B", value: 84),
            GradeEntry(name: "B-", value: 80), GradeEntry(name: "C+", value: 77),
            GradeEntry(name: "C", value: 74), GradeEntry(name: "C-", value: 70),
            GradeEntry(name: "D+", value: 67), GradeEntry(name: "D", value: 64),
            GradeEntry(name: "D-", value: 61), GradeEntry(name: "F", value: 0), ]

        public init(title: String = "Standard", grading_scheme_entry: [GradeEntry] = StandardGradingScheme) {
            self.title = title
            self.grading_scheme_entry = grading_scheme_entry
        }
    }

    public struct GradeEntry: Encodable {
        public let name: String
        public let value: Int
    }
}
