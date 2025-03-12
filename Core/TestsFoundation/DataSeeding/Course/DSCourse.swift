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

import Foundation

public struct DSCourse: Codable {
    public let id: String
    public let name: String
    public let time_zone: String?
    public var syllabus_body: String?
    public let account_id: String?
    public var homeroom_course: Bool = false
    public let start_at: Date?
    public let end_at: Date?
    public let default_view: String?

    public init(
        id: String,
        name: String,
        time_zone: String? = nil,
        syllabus_body: String? = nil,
        account_id: String? = nil,
        homeroom_course: Bool = false,
        start_at: Date? = nil,
        end_at: Date? = nil,
        default_view: String? = nil
    ) {
        self.id = id
        self.name = name
        self.time_zone = time_zone
        self.syllabus_body = syllabus_body
        self.account_id = account_id
        self.homeroom_course = homeroom_course
        self.start_at = start_at
        self.end_at = end_at
        self.default_view = default_view
    }
}
