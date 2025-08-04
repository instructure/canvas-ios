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

    public private(set) var id: String
    public private(set) var context: Context

    public init(id: String, context: Context) {
        self.id = id
        self.context = context
    }

    public var cacheKey: String? {
        "\(context.pathComponent)/gradingStandards/\(id)"
    }

    public var scope: Scope {
        return .where(#keyPath(CDGradingStandard.id), equals: id)
    }

    public var request: GetGradingStandardRequest {
        return GetGradingStandardRequest(context: context, gradingStandardId: id)
    }

    public func write(response: APIGradingStandard?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let response {
            CDGradingStandard.save(response, in: client)
        }
    }
}
