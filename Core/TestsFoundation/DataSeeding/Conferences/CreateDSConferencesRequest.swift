//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Core

public struct CreateDSConferencesRequest: APIRequestable {
    public typealias Response = DSConference

    public let method = APIMethod.post
    public let path: String
    public let body: Body?

    public init(course: DSCourse, body: Body) {
        self.path = "courses/\(course.id)/conferences"
        self.body = body
    }
}

extension CreateDSConferencesRequest {
    public struct Body: Encodable {
        let title: String
        let conference_type: String = "BigBlueButton"
        let duration: TimeInterval?
        let description: String
        let long_running: Int
        let web_conference: WebConference

        public init(web_conference: WebConference) {
            self.web_conference = web_conference
            self.title = web_conference.title
            self.duration = web_conference.duration
            self.description = web_conference.description
            self.long_running = web_conference.long_running
        }
    }

    public struct WebConference: Encodable {
        let title: String
        let conference_type: String = "BigBlueButton"
        let duration: TimeInterval?
        let description: String
        let long_running: Int

        public init(title: String, duration: TimeInterval? = nil, description: String, long_running: Int = 1) {
            self.title = title
            self.description = description
            self.long_running = long_running
            self.duration = long_running == 1 ? nil : duration
        }
    }
}
