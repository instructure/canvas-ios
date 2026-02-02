//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct ReportBugRequest: APIRequestable {

    typealias Response = ReportBugResponse

    var path: String = "error_reports"
    var method: APIMethod = .post
    var query: [APIQueryItem] = []

    private let subject: String
    private let topic: String
    private let description: String
    private let email: String
    private let url: String

    init(
        subject: String,
        topic: String,
        description: String,
        email: String,
        url: String
    ) {
        self.subject = subject
        self.topic = topic
        self.description = description
        self.email = email
        self.url = url
        self.query = [
            .value("error[subject]", subject),
            .value("error[url]", url),
            .value("error[email]", email),
            .value("error[comments]", description),
            .value("error[user_roles]", "student"),
            .value("error[user_perceived_severity]", topic)
        ]
    }
}

struct ReportBugResponse: Codable {
    let logged: Bool?
    let id: String?
}
