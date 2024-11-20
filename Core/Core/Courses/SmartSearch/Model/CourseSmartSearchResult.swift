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

// https://canvas.instructure.com/doc/api/smart_search.html
public struct CourseSmartSearchResult: Codable, Identifiable, Equatable {
    enum ContentType: String, Codable, CaseIterable {
        case page = "WikiPage"
        case assignment = "Assignment"
        case announcement = "Announcement"
        case discussion = "DiscussionTopic"

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

    public var id: ID {
        content_id
    }
}

struct CourseSmartSearchResultsSection {
    let type: CourseSmartSearchResultType
    var expanded: Bool = false
    let results: [CourseSmartSearchResult]
}

// MARK: - Route Path

extension CourseSmartSearchResult {

    var pathComponent: String {

        let instanceType: String
        switch content_type {
        case .assignment:
            instanceType = "assignments"
        case .page:
            instanceType = "wiki"
        case .announcement:
            instanceType = "announcements"
        case .discussion:
            instanceType = "discussion_topics"
        }
        return "\(instanceType)/\(content_id.value)"
    }
}

// MARK: - UI Helpers

typealias CourseSmartSearchResultType = CourseSmartSearchResult.ContentType
extension CourseSmartSearchResultType {

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
}

extension CourseSmartSearchResult {

    var distanceDots: Int {
        let strength = 1 - distance
        return Int(round(strength * 4))
    }

    var strengthColor: Color {
        return distanceDots >= 3 ? Color.borderSuccess : Color.borderWarning
    }
}
