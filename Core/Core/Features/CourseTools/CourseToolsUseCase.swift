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

import CoreData
import Foundation

public final class CourseToolsUseCase: APIUseCase {
    // MARK: - Typealias

    public typealias Model = CDHCourseTools
    public typealias Request = GetCourseNavigationToolsRequest

    // MARK: - Properties

    public var cacheKey: String? { "Course-Navigation-Tools-\(courseContextsCodes.joined(separator: ","))" }

    public var request: GetCourseNavigationToolsRequest {
        .init(courseContextsCodes: courseContextsCodes)
    }

    private let courseContextsCodes: [String]

    public init(courseContextsCodes: [String]) {
        self.courseContextsCodes = courseContextsCodes
    }

    public func write(
        response: [CourseNavigationTool]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let tools = response else {
            return
        }
        tools.forEach {
            CDHCourseTools.save(
                apiEntity: $0,
                courseContextsCodes: courseContextsCodes.joined(separator: ","),
                in: client
            )
        }
    }

    public var scope: Scope {
        Scope(
            predicate: NSPredicate(format: "%K == %@", #keyPath(CDHCourseTools.courseContextsCodes), courseContextsCodes.joined(separator: ",")),
            order: []
        )
    }
}
