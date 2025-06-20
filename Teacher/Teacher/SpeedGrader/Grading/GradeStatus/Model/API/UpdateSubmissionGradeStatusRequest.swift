//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

public class UpdateSubmissionGradeStatusRequest: APIGraphQLRequestable {
    public typealias Response = APINoContent

    public struct Input: Codable, Equatable {
        public let submissionId: String
        public let customGradeStatusId: String?
        public let latePolicyStatus: String?
    }

    public struct Variables: Codable, Equatable {
        public let input: Input
    }

    public let variables: Variables

    public init(
        submissionId: String,
        customGradeStatusId: String? = nil,
        latePolicyStatus: String? = nil
    ) {
        variables = Variables(
            input: Input(
                submissionId: submissionId,
                customGradeStatusId: customGradeStatusId,
                latePolicyStatus: latePolicyStatus
            )
        )
    }

    public class var query: String { """
        mutation \(operationName)($input: UpdateSubmissionsGradeStatusInput!) {
          updateSubmissionGradeStatus(input: $input) {
            __typename
          }
        }
        """
    }
}
