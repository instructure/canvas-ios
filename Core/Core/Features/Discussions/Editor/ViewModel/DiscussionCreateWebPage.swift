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

public struct DiscussionCreateWebPage: EmbeddedWebPage {
    public let urlPathComponent: String = "/discussion_topics/new"
    public let navigationBarTitle: String
    public let queryItems: [URLQueryItem]
    public let assetID: String? = nil

    public init(isAnnouncement: Bool) {
        navigationBarTitle = isAnnouncement ? String(localized: "New Announcement", bundle: .core)
                                            : String(localized: "New Discussion", bundle: .core)
        queryItems = isAnnouncement ? [URLQueryItem(name: "is_announcement", value: "true")]
                                    : []
    }
}
