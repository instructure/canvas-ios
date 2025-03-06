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
import CoreData

final class HGetModules: APIUseCase {
    typealias Model = Module
    private let courseID: String

    var cacheKey: String? {
        "Get-Modules-\(courseID)"
    }

    var scope: Scope {
        .where(#keyPath(Module.courseID), equals: courseID)
    }

    var request: HGetModulesRequest {
        .init(courseID: courseID)
    }

    init(courseID: String) {
        self.courseID = courseID
    }

    func write(response: [APIModule]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else {
            return
        }
        for module in response {
            Module.save(module, forCourse: courseID, in: client)
        }
    }
}
