//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/announcements.html#method.announcements_api.index
public struct GetAllAnnouncementsRequest: APIRequestable {
    public typealias Response = [APIDiscussionTopic]
    var contextCodes: [String] = []
    private let activeOnly: Bool?
    private let latestOnly: Bool?
    private let startDate: Date?
    private let endDate: Date?

    public init(
        contextCodes: [String],
        activeOnly: Bool? = nil,
        latestOnly: Bool? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.contextCodes = contextCodes
        self.activeOnly = activeOnly
        self.latestOnly = latestOnly
        self.startDate = startDate
        self.endDate = endDate
    }

    public var path = "announcements"
    public var query: [APIQueryItem] {[
        .array("context_codes", contextCodes),
        .optionalBool("active_only", activeOnly),
        .optionalBool("latest_only", latestOnly),
        .optionalValue("start_date", startDate?.isoString()),
        .optionalValue("end_date", endDate?.isoString())
    ]}
}
