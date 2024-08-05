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

// Currently this removes from CoreData only the one event which initiated the deletion.
// It doesn't handle removing related repeated items from CoreData.
// This is OK for now, because we rely on force refreshing everything.
final class DeleteCalendarEvent: DeleteUseCase {
    typealias Model = CalendarEvent

    let request: DeleteCalendarEventRequest
    let cacheKey: String? = nil
    var scope: Scope { .where(#keyPath(CalendarEvent.id), equals: id) }

    private let id: String

    init(id: String, seriesModificationType: APICalendarEventSeriesModificationType?) {
        self.id = id
        self.request = DeleteCalendarEventRequest(
            id: id,
            body: .init(which: seriesModificationType)
        )
    }
}
