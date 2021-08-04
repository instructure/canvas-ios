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

    init(weekModels: [K5ScheduleWeekViewModel]) {
        self.weekModels = weekModels
        self.defaultWeekIndex = weekModels.count / 2 + 1
    }

    #endif
    
    public init(currentDate: Date = Date(), calendar: Calendar = Calendar.current) {
        let currentWeekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        let currentWeekEndDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStartDate)!
        var weekModels: [K5ScheduleWeekViewModel] = []

        for i in weekRangeFromCurrentWeek {
            let weekStartDate = calendar.date(byAdding: .weekOfYear, value: i, to: currentWeekStartDate)!
            let weekEndDate = calendar.date(byAdding: .weekOfYear, value: i, to: currentWeekEndDate)!
            weekModels.append(K5ScheduleWeekViewModel(weekRange: weekStartDate..<weekEndDate, isTodayButtonAvailable: (i == defaultWeekIndex), days: []))
        }

        self.weekModels = weekModels
    }
}

extension K5ScheduleViewModel: Refreshable {

    public func refresh(completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion()
        }
    }
}
