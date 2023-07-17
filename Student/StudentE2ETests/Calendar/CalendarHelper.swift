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

import TestsFoundation

public class CalendarHelper: BaseHelper {
    @discardableResult
    public static func createCalendarEvent(course: DSCourse,
                                           title: String = "Sample Calendar Event",
                                           description: String = "Be there or be square!") -> DSCalendarEvent {
        let calendarEvent = CreateDSCalendarEventRequest.RequestedDSCalendarEvent(courseId: course.id,
                                                                                  title: title,
                                                                                  description: description)
        let requestBody = CreateDSCalendarEventRequest.Body(calendar_event: calendarEvent)
        return seeder.createCalendarEvent(requestBody: requestBody)
    }
}
