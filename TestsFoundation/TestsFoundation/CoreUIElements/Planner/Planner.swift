//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import TestsFoundation

enum PlannerCalendar: String, ElementWrapper {
    case profileButton, addNoteButton, todayButton
    case yearLabel, monthButton, filterButton

    static func dayButton(for date: Date) -> Element {
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return dayButton(year: year, month: month, day: day)
    }
    static func dayButton(year: Int, month: Int, day: Int) -> Element {
        return app.find(id: "PlannerCalendar.dayButton.\(year)-\(month)-\(day)")
    }
}

enum PlannerList: String, ElementWrapper {
    case emptyTitle, emptyLabel

    static func event(id: String) -> Element {
        return app.find(id: "PlannerList.event.\(id)")
    }
}

enum PlannerFilter: String, ElementWrapper {
    case headerLabel, emptyTitleLabel, emptyMessageLabel

    static func cell(section: Int, row: Int) -> Element {
        return app.find(id: "PlannerFilter.section.\(section).row.\(row)")
    }
}
