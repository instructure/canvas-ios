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

import Foundation
import CoreData

final class CreateCalendarEvent: APIUseCase {
    typealias Model = CalendarEvent

    let request: PostCalendarEventRequest
    let cacheKey: String? = nil
    let scope: Scope = .all()

    init(
        context_code: String,
        title: String,
        description: String?,
        start_at: Date?,
        end_at: Date?,
        all_day: Bool,
        location_name: String?,
        location_address: String?
    ) {
        self.request = PostCalendarEventRequest(
            body: .init(
                calendar_event: .init(
                    context_code: context_code,
                    title: title,
                    description: description,
                    start_at: start_at,
                    end_at: end_at,
                    all_day: all_day,
                    location_name: location_name,
                    location_address: location_address
                )
            )
        )
    }
}

