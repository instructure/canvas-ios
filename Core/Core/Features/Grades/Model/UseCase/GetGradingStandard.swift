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

import Foundation
import CoreData

public class GetGradingStandard: APIUseCase {
    public typealias Model = CDGradingStandard

    public private(set) var gradingStandardId: String
    public private(set) var contextId: String
    public private(set) var contextType: String

    public init(gradingStandardId: String, contextId: String, contextType: String) {
        self.gradingStandardId = gradingStandardId
        self.contextId = contextId
        self.contextType = contextType
    }

    public var cacheKey: String? {
        return switch contextType {
        case "Course":
            "accounts/\(contextId)/gradingStandards/\(gradingStandardId)"
        default:
            "courses/\(contextId)/gradingStandards/\(gradingStandardId)"
        }
    }

    public var scope: Scope {
        return .where(#keyPath(CDGradingStandard.id), equals: gradingStandardId)
    }

    public var request: GetGradingStandardRequest {
        return GetGradingStandardRequest(contextId: contextId, contextType: contextType, gradingStandardId: gradingStandardId)
    }

    public func write(response: APIGradingStandard?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let response {
            CDGradingStandard.save(response, in: client)
        }
    }
}
