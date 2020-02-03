//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/search.html#method.search.recipients
public struct APISearchRecipient: Codable, Equatable {
    public let id: ID
    public let name: String
    public let full_name: String
    public let pronouns: String?
    public let avatar_url: APIURL?
    public let type: APISearchRecipientContext?
    public let common_courses: [String: [String]]
}

public enum APISearchRecipientContext: String, Codable {
    case context
    case course
    case section
    case group
    case user
}
