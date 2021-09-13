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

public class K5ScheduleViewModel: ObservableObject {
    public let weekModels: [K5ScheduleWeekViewModel]
    public private(set) var defaultWeekIndex = 26
    private let weekRangeFromCurrentWeek = -26...26

    #if DEBUG

    // MARK: - Preview Support

    init(weekModels: [K5ScheduleWeekViewModel]) {
        self.weekModels = weekModels
        self.defaultWeekIndex = weekModels.count / 2
    }

    // MARK: Preview Support -

    #endif

    public init(currentDate: Date = Date(), calendar: Calendar = Calendar.current) {
        let currentWeekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        let currentWeekEndDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStartDate)!
        var weekModels: [K5ScheduleWeekViewModel] = []

        for i in weekRangeFromCurrentWeek {
            let weekStartDate = calendar.date(byAdding: .weekOfYear, value: i, to: currentWeekStartDate)!
            let weekEndDate = calendar.date(byAdding: .weekOfYear, value: i, to: currentWeekEndDate)!
            let dayModels = Self.dayModelsForWeek(weekStartDate: weekStartDate, calendar: calendar)
            let isTodayButtonVisible = (currentDate >= weekStartDate && currentDate < weekEndDate)
            weekModels.append(K5ScheduleWeekViewModel(weekRange: weekStartDate..<weekEndDate, isTodayButtonAvailable: isTodayButtonVisible, days: dayModels))
        }

        self.weekModels = weekModels
    }

    public func isOnFirstPage(currentPageIndex: Int) -> Bool {
        currentPageIndex == 0
    }

    public func isOnLastPage(currentPageIndex: Int) -> Bool {
        currentPageIndex == weekModels.count - 1
    }

    private static func dayModelsForWeek(weekStartDate: Date, calendar: Calendar) -> [K5ScheduleDayViewModel] {
        var dayModels: [K5ScheduleDayViewModel] = []

        for dayIndex in 0..<7 {
            let dayStartDate = calendar.date(byAdding: .day, value: dayIndex, to: weekStartDate)!
            let dayEndDate = calendar.date(byAdding: .day, value: 1, to: dayStartDate)!
            dayModels.append(K5ScheduleDayViewModel(range: dayStartDate..<dayEndDate, calendar: calendar))
        }

        return dayModels
    }
}
