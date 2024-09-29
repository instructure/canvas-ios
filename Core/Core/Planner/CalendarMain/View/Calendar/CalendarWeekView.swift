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

struct CalendarWeekView: View {
    @Binding var calendarDay: CalendarDay

    var body: some View {
        let calendarWeek = calendarDay.week
        let weekdays = calendarDay.calendar.orderedWeekdays
        Grid(horizontalSpacing: 0) {
            GridRow {
                ForEach(weekdays, id: \.self) { day in
                    let selected = calendarDay.weekday == day
                    CalendarWeekDayView(weekday: day, week: calendarWeek, selected: selected)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            calendarDay = calendarDay.week.day(ofWeekday: day)
                        }
                }
            }
        }
    }
}

struct CalendarStaticWeekView: View {
    let week: CalendarWeek

    var body: some View {
        let weekdays = week.calendar.orderedWeekdays
        Grid(horizontalSpacing: 0) {
            GridRow {
                ForEach(weekdays, id: \.self) { day in
                    CalendarWeekDayView(weekday: day, week: week)
                }
            }
        }
    }
}

private struct CalendarWeekDayView: View {
    @EnvironmentObject var viewModel: PlannerViewModel

    @State private var eventsCount: Int = 0

    let weekday: Int
    let week: CalendarWeek
    var selected: Bool = false

    var body: some View {
        let title = week.title(forWeekday: weekday)

        HStack {
            Spacer()
            Text(title)
                .font(.regular16)
                .foregroundStyle(selected ? Color.white : .primary)
                .padding(.vertical, 10)
                .background(alignment: .bottom) {
                    if !selected, eventsCount > 0 {
                        HStack(spacing: 3) {
                            ForEach(0 ..< eventsCount, id: \.self) { _ in
                                Circle().fill(Color.blue).frame(width: 5, height: 5)
                            }
                        }
                    }
                }
            Spacer()
        }
        .padding(.vertical, 5)
        .background {
            if selected {
                Circle().inset(by: 5).fill(Color.blue)
            }
        }
        .onReceive(viewModel.$plannables) { newList in
            let date = week.date(ofWeekday: weekday)
            let newCount = newList
                .compactMap({ $0.date })
                .filter({ week.calendar.isDate($0, inSameDayAs: date) })
                .prefix(3)
                .count
            eventsCount = newCount
        }
    }
}
