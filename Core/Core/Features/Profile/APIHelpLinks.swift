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
public struct APIHelpLink: Codable {

    let id: String?
    let text: String?
    let subtext: String?
    // let type: 'default' | 'custom'
    let available_to: [HelpLinkEnrollment]?
    let url: URL?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        text = try container.decodeIfPresent(String.self, forKey: .text)
        subtext = try container.decodeIfPresent(String.self, forKey: .subtext)
        available_to = try container.decodeIfPresent([HelpLinkEnrollment].self, forKey: .available_to)
        do {
            url = try container.decode(URL.self, forKey: .url)
        } catch( _) {
            url = nil
        }
    }

    public init(id: String?, text: String?, subtext: String?, available_to: [HelpLinkEnrollment]?, url: URL?) {
        self.id = id
        self.text = text
        self.subtext = subtext
        self.available_to = available_to
        self.url = url
    }
}

public enum HelpLinkEnrollment: String, Codable {
    case admin, observer, student, teacher, unenrolled, user
}

#if DEBUG
extension APIHelpLinks {
    public static func make(
        help_link_name: String = "Help",
        help_link_icon: String = "help",
        default_help_links: [APIHelpLink] = [
            .instructorQuestion,
            .searchGuides,
            .reportProblem
        ],
        custom_help_links: [APIHelpLink] = []
    ) -> APIHelpLinks {
        return APIHelpLinks(
            help_link_name: help_link_name,
            help_link_icon: help_link_icon,
            default_help_links: default_help_links,
            custom_help_links: custom_help_links
        )
    }
}

extension APIHelpLink {
    public static func make(
        id: String? = "instructor_question",
        text: String? = "Ask Your Instructor a Question",
        subtext: String? = "Questions are submitted to your instructor",
        available_to: [HelpLinkEnrollment]? = [ .student ],
        url: URL? = URL(string: "#teacher_feedback")!
    ) -> APIHelpLink {
        return APIHelpLink(
            id: id,
            text: text,
            subtext: subtext,
            available_to: available_to,
            url: url
        )
    }

    public static var instructorQuestion = APIHelpLink.make()

    public static var searchGuides = APIHelpLink.make(
        id: "search_the_canvas_guides",
        text: "Search the Canvas Guides",
        subtext: "Find answers to common questions",
        available_to: [ .user, .student, .teacher, .admin, .observer, .unenrolled ],
        url: URL(string: "http://community.canvaslms.com/community/answers/guides")!
    )

    public static var reportProblem = APIHelpLink.make(
        id: "report_a_problem",
        text: "Report a Problem",
        subtext: "If Canvas misbehaves, tell us about it",
        available_to: [ .user, .student, .teacher, .admin, .observer, .unenrolled ],
        url: URL(string: "#create_ticket")!
    )
}
#endif

// https://canvas.instructure.com/doc/api/accounts.html#method.accounts.help_links
public struct GetAccountHelpLinksRequest: APIRequestable {
    public typealias Response = APIHelpLinks
    public let path = "accounts/self/help_links"
}
