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

// https://canvas.instructure.com/doc/api/accounts.html#HelpLinks
public struct APIHelpLinks: Codable {
    let help_link_name: String
    let help_link_icon: String
    let default_help_links: [APIHelpLink]
    let custom_help_links: [APIHelpLink]
}

// https://canvas.instructure.com/doc/api/accounts.html#HelpLink
struct APIHelpLink: Codable {
    let id: String
    let text: String
    let subtext: String?
    // let type: 'default' | 'custom'
    let available_to: [HelpLinkEnrollment]
    let url: URL
}

public enum HelpLinkEnrollment: String, Codable {
    case admin, observer, student, teacher, unenrolled, user
}

// https://canvas.instructure.com/doc/api/accounts.html#method.accounts.help_links
public struct GetAccountHelpLinksRequest: APIRequestable {
    public typealias Response = APIHelpLinks
    public let path = "accounts/self/help_links"
}
