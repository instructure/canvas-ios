//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import SwiftUI



struct SearchResult: Codable, Identifiable {
    var id: ID { content_id }

    enum ContentType: String, Codable {
        case page = "WikiPage"
        case assignment = "Assignment"
        case announcement = "Announcement"
        case discussion = "DiscussionTopic"

        var sortOrder: Int {
            switch self {
            case .page:
                return 1
            case .assignment:
                return 2
            case .announcement:
                return 3
            case .discussion:
                return 4
            }
        }

        var filterValue: String {
            switch self {
            case .page:
                return "pages"
            case .assignment:
                return "assignments"
            case .announcement:
                return "announcements"
            case .discussion:
                return "discussion_topics"
            }
        }
    }

    let content_id: ID
    let content_type: ContentType
    let readable_type: String
    let title: String
    let body: String
    let html_url: URL?
    let distance: Double
    let relevance: Int
}

struct SearchResultsSection {
    let type: SearchResult.ContentType
    var expanded: Bool = false
    let results: [SearchResult]
}

// MARK: - UI Helpers

typealias SearchResultType = SearchResult.ContentType
extension SearchResultType {

    var title: String {
        switch self {
        case .page:
            return "Page"
        case .discussion:
            return "Discussion"
        case .assignment:
            return "Assignment"
        case .announcement:
            return "Announcement"
        }
    }

    var icon: Image {
        switch self {
        case .page:
            Image.documentLine
        case .discussion:
            Image.discussionLine
        case .assignment:
            Image.assignmentLine
        case .announcement:
            Image.announcementLine
        }
    }
}

extension SearchResult {

    var distanceDots: Int {
        let strength = 1 - distance
        return Int(ceil(strength * 4))
    }

    var strengthColor: Color {
        return distanceDots >= 3 ? Color.borderSuccess : Color.borderWarning
    }
}

// MARK: - Mocks

extension SearchResult {

    static func make(_ type: ContentType, title: String, body: String) -> SearchResult {
        return SearchResult(
            content_id: ID(integerLiteral: Int.random(in: 1000 ... 9999)),
            content_type: type,
            readable_type: type.title,
            title: title,
            body: body,
            html_url: URL(string: "https://www.instructure.com"),
            distance: Double.random(in: 0.1 ... 1.0),
            relevance: Int.random(in: 1 ... 40)
        )
    }

    static var simpleExample: [SearchResult] {
        return [
            .make(
                .announcement,
                title: "Student Challenge",
                body: "We’re thrilled to announce the Swift Student Challenge 2025. The Challenge provides the next generation of student developers the opportunity to showcase their creativity and coding skills by building app playgrounds with Swift."
            ),
            .make(
                .assignment,
                title: "Entrepreneur Camp",
                body: "Apple Entrepreneur Camp supports underrepresented founders and developers, and encourages the pipeline and longevity of these entrepreneurs in technology. Attendees benefit from one-on-one code-level guidance, receive unprecedented access to Apple engineers and experts, and become part of the extended global network of Apple Entrepreneur Camp alumni."
            ),
            .make(
                .page,
                title: "Petra",
                body: "Petra is a famous archaeological site in Jordan's southwestern desert. Dating to around 300 B.C., it was the capital of the Nabatean Kingdom. Accessed via a narrow canyon called Al Siq, it contains tombs and temples carved into pink sandstone cliffs, earning its nickname, the \"Rose City.\" Perhaps its most famous structure is 45m-high Al Khazneh, a temple with an ornate, Greek-style facade, and known as The Treasury. "
            ),
            .make(
                .announcement,
                title: "Student Challenge",
                body: "We’re thrilled to announce the Swift Student Challenge 2025. The Challenge provides the next generation of student developers the opportunity to showcase their creativity and coding skills by building app playgrounds with Swift."
            ),
            .make(
                .page,
                title: "Petra",
                body: "Petra is a famous archaeological site in Jordan's southwestern desert. Dating to around 300 B.C., it was the capital of the Nabatean Kingdom. Accessed via a narrow canyon called Al Siq, it contains tombs and temples carved into pink sandstone cliffs, earning its nickname, the \"Rose City.\" Perhaps its most famous structure is 45m-high Al Khazneh, a temple with an ornate, Greek-style facade, and known as The Treasury. "
            ),
            .make(
                .announcement,
                title: "Student Challenge",
                body: "We’re thrilled to announce the Swift Student Challenge 2025. The Challenge provides the next generation of student developers the opportunity to showcase their creativity and coding skills by building app playgrounds with Swift."
            ),
            .make(
                .assignment,
                title: "Entrepreneur Camp",
                body: "Apple Entrepreneur Camp supports underrepresented founders and developers, and encourages the pipeline and longevity of these entrepreneurs in technology. Attendees benefit from one-on-one code-level guidance, receive unprecedented access to Apple engineers and experts, and become part of the extended global network of Apple Entrepreneur Camp alumni."
            )
        ]
    }
}
