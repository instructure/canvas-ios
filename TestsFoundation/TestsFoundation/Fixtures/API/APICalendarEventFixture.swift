//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

extension APICalendarEvent {
    public static func make(
        id: ID = "1",
        html_url: URL = URL(string: "https://narmstrong.instructure.com/calendar?event_id=10&include_contexts=course_1")!,
        title: String = "calendar event #1",
        start_at: Date? = Date(fromISOString: "2018-05-18T06:00:00Z"),
        end_at: Date? = Date(fromISOString: "2018-05-18T06:00:00Z"),
        type: String? = "event",
        context_code: String = "course_1"
    ) -> APICalendarEvent {
        return APICalendarEvent(
            id: id,
            html_url: html_url,
            title: title,
            start_at: start_at,
            end_at: end_at,
            type: type,
            context_code: context_code
        )
    }
}
