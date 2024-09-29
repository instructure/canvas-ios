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

struct CalendarMonthView: View {
    @Binding var calendarDay: CalendarDay
    @Binding var offsets: [Int: CGFloat]

    private var month: CalendarMonth { calendarDay.month }
    private let space = UUID()

    var body: some View {
        let calendarWeek = calendarDay.week
        let calendarWeekday = calendarDay.weekday
        let weekdays = calendarDay.calendar.orderedWeekdays
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {

            ForEach(month.weeks, id: \.weekOfMonth) { week in

                GridRow {

                    ForEach(weekdays, id: \.self) { day in
                        let selected = calendarWeek == week && calendarWeekday == day

                        CalendarMonthDayView(weekday: day, week: week, selected: selected)
                            .contentShape(Rectangle())
                            .onTapGesture {

                                let newDay = week.day(ofWeekday: day)
                                if newDay.month == calendarDay.month {
                                    calendarDay = newDay
                                } else {
                                    withAnimation {
                                        calendarDay = newDay
                                    }
                                }
                            }
                    }
                }
                .background {
                    if offsets.keys.contains(week.weekOfMonth) == false {
                        GeometryReader { g in
                            Color.clear.preference(
                                key: WeekOffsetKey.self,
                                value: WeekOffset(
                                    week: week.weekOfMonth,
                                    offset: g.frame(in: .global).origin
                                )
                            )
                        }
                        .onPreferenceChange(WeekOffsetKey.self) { offset in
                            offsets[offset.week] = offset.offset.y
                        }
                    }
                }
            }
        }
    }
}

struct CalendarStaticMonthView: View {
    let month: CalendarMonth
    var body: some View {
        let weekdays = month.calendar.orderedWeekdays
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(month.weeks, id: \.weekOfMonth) { week in
                GridRow {
                    ForEach(weekdays, id: \.self) { day in
                        CalendarMonthDayView(weekday: day, week: week)
                    }
                }
            }
        }
    }
}

struct CalendarMonthDayView: View {
    @EnvironmentObject var viewModel: PlannerViewModel
    @State private var eventsCount: Int = 0

    let weekday: Int
    let week: CalendarWeek
    var selected: Bool = false

    var body: some View {
        let isValid = week.validate(weekday: weekday)
        let title = week.title(forWeekday: weekday)
        let color = selected ? Color.white : .primary

        HStack {
            Spacer()
            Text(title)
                .font(.regular16)
                .foregroundStyle(isValid ? color : Color.secondary)
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) {
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

private struct WeekOffset: Equatable {
    let week: Int
    let offset: CGPoint
}

private struct WeekOffsetKey: PreferenceKey {
    static var defaultValue = WeekOffset(week: 0, offset: .zero)
    static func reduce(value: inout WeekOffset, nextValue: () -> WeekOffset) { }
}
