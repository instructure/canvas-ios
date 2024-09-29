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

import SwiftUI

extension Calendar {

    var weekdaysCount: Int {
        return maximumRange(of: .weekday)?.count ?? 7
    }

    var orderedWeekdays: [Int] {
        return Array(firstWeekday ... weekdaysCount) + Array(1 ..< firstWeekday)
    }
}

extension Range<Int> {
    static let zero: Range<Int> = 0 ..< 0
}

extension CGSize {
    static let small = CGSize(width: 100, height: 100)
}

extension FormatStyle where Self == Date.FormatStyle {
    static func dateTime(calendar: Calendar) -> Self {
        var format = dateTime
        format.calendar = calendar
        return format
    }
}

extension Date {

    public func formatted(date: Date.FormatStyle.DateStyle,
                          time: Date.FormatStyle.TimeStyle,
                          locale: Locale = .autoupdatingCurrent,
                          calendar: Calendar = .autoupdatingCurrent,
                          timeZone: TimeZone = .autoupdatingCurrent,
                          capitalizationContext: FormatStyleCapitalizationContext = .unknown) -> String {

        return formatted(
            Date.FormatStyle(date: date,
                             time: time,
                             locale: locale,
                             calendar: calendar,
                             timeZone: timeZone,
                             capitalizationContext: capitalizationContext)
        )
    }
}

@discardableResult
public func withAnimation<Result>(
    duration: Double,
    _ body: () throws -> Result,
    completion: @escaping () -> Void
) rethrows -> Result {
    if #available(iOS 17.0, *) {
        return try withAnimation(.spring(duration: duration), body, completion: completion)
    } else {
        let result = try withAnimation(.spring(duration: duration), body)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: completion)
        return result
    }
}
