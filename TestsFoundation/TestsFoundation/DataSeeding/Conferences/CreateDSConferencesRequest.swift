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
    public let form: APIFormData

    public init(course: DSCourse,
                title: String,
                duration: TimeInterval,
                description: String) {
        self.path = "/courses/\(course.id)/conferences"

        var form = APIFormData()
        form.append((key: "_method", value: APIFormDatum.string("POST")))
        form.append((key: "title", value: APIFormDatum.string(title.replacingOccurrences(of: " ", with: "+"))))
        form.append((key: "conference_type", value: APIFormDatum.string("BigBlueButton")))
        form.append((key: "duration", value: APIFormDatum.string(String(Int(duration)))))
        form.append((key: "description", value: APIFormDatum.string(description.replacingOccurrences(of: " ", with: "+"))))
        self.form = form
    }
}
