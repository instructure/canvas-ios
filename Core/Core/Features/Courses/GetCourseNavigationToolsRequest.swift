//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/external_tools.html#method.external_tools.all_visible_nav_tools
public struct GetCourseNavigationToolsRequest: APIRequestable {
    public typealias Response = [CourseNavigationTool]

    public var path: String { "external_tools/visible_course_nav_tools" }
    public var query: [APIQueryItem] { [.array("context_codes", courseContextsCodes)] }
    private let courseContextsCodes: [String]

    public init(courseContextsCodes: [String]) {
        self.courseContextsCodes = courseContextsCodes
    }
}

public struct CourseNavigationTool: Codable {
    public struct CourseNavigation: Codable {
        let text: String?
        let url: URL?
        let label: String?
        @SafeURL private(set) var icon_url: URL?
    }

    public let id: String?
    public let context_name: String?
    public let context_id: String?
    public let course_navigation: CourseNavigation?
    public let name: String?
    @SafeURL public private(set) var url: URL?
}
