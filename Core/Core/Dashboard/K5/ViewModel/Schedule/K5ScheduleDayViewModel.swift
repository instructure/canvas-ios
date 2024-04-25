//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

/**
 Model for a single day in the schedule view, this holds multiple subjects.
 */
public class K5ScheduleDayViewModel: Identifiable, ObservableObject {
    public enum Subject {
        case loading
        case empty
        case data([K5ScheduleSubjectViewModel])
    }
    public let range: Range<Date>
    public let weekday: String
    public let date: String
    @Published public var subjects: Subject
    @Published public var missingItems: [K5ScheduleEntryViewModel] = []

    public init(range: Range<Date>, calendar: Calendar) {
        if calendar.isDateInToday(range.lowerBound) {
            self.weekday = String(localized: "Today", bundle: .core)
        } else if calendar.isDateInTomorrow(range.lowerBound) {
            self.weekday = String(localized: "Tomorrow", bundle: .core)
        } else {
            self.weekday = range.lowerBound.weekdayName
        }

        self.date = range.lowerBound.dayInMonth
        self.subjects = .loading
        self.range = range
    }

#if DEBUG

    // MARK: - Preview Support

    /**
     Use only for SwiftUI previews.
    */
    public init(weekday: String, date: String, subjects: Subject, missingItems: [K5ScheduleEntryViewModel] = []) {
        self.weekday = weekday
        self.date = date
        self.subjects = subjects
        self.missingItems = missingItems
        self.range = Date()..<Date()
    }

    // MARK: Preview Support -

#endif
}

extension K5ScheduleDayViewModel: Equatable {

    public static func == (lhs: K5ScheduleDayViewModel, rhs: K5ScheduleDayViewModel) -> Bool {
        lhs.weekday == rhs.weekday && lhs.date == rhs.date
    }
}
