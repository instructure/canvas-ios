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
import Combine

struct CalendarMonthView: View {
    @Environment(\.plannerViewModel) var plannerModel

    @Binding var calendarDay: CalendarDay
    @Binding var offsets: [Int: CGFloat]

    @State fileprivate var dates: [Date] = []
    fileprivate var month: CalendarMonth { calendarDay.month }

    var body: some View {

        Grid(horizontalSpacing: 0, verticalSpacing: 0) {

            ForEach(month.weeks) { week in

                GridRow {

                    ForEach(week.weekdays) { wday in
                        let selected = calendarDay.date == wday.date
                        let count = eventsCount(for: wday)

                        CalendarMonthDayView(day: wday, dots: count, selected: selected)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if wday.isValid {
                                    calendarDay = wday.calendarDay
                                } else {
                                    withAnimation {
                                        calendarDay = wday.calendarDay
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
        .onReceive(eventDatesPublisher) { newList in
            self.dates = newList
        }
    }
}

struct CalendarStaticMonthView: View {
    @Environment(\.plannerViewModel) var plannerModel
    @State fileprivate var dates: [Date] = []
    let month: CalendarMonth

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(month.weeks) { week in
                GridRow {
                    ForEach(week.weekdays) { wday in
                        CalendarMonthDayView(day: wday, dots: eventsCount(for: wday))
                    }
                }
            }
        }
        .onReceive(eventDatesPublisher) { newList in
            self.dates = newList
        }
    }
}

struct CalendarMonthDayView: View {
    let day: CalendarWeekday
    let dots: Int
    var dimsInvalidDays: Bool = true
    var selected: Bool = false

    private var textColor: Color {
        if selected { return .white }
        guard dimsInvalidDays else { return .primary }
        return day.isValid ? .primary : .secondary
    }

    var body: some View {

        HStack {
            Spacer()
            Text(day.title)
                .font(.regular16)
                .foregroundStyle(textColor)
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) {
                    if showsDots {
                        HStack(spacing: 3) {
                            ForEach(0 ..< dots, id: \.self) { _ in
                                Circle().fill(Color.blue).frame(width: 4, height: 4).transition(.opacity)
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
    }

    private var showsDots: Bool {
        dots > 0 && selected == false
    }
}

// MARK: - Dots Fetching

private protocol CalendarMonthViewProtocol: View {
    var plannerModel: PlannerViewModelEnvironmentWrapper { get }
    var month: CalendarMonth { get }
    var dates: [Date] { get }
}

extension CalendarMonthViewProtocol {

    func eventsCount(for day: CalendarWeekday) -> Int {
        return dates.filter({ day.containsDate($0) }).prefix(3).count
    }

    var eventDatesPublisher: AnyPublisher<[Date], Never> {
        guard let model = plannerModel.model else {
            return Just([]).eraseToAnyPublisher()
        }
        return model
            .$plannables
            .map({ newList in
                return newList
                    .compactMap({ $0.date })
                    .filter({ month.containsDateInWeeks($0) })
            })
            .eraseToAnyPublisher()
    }
}

extension CalendarMonthView: CalendarMonthViewProtocol {}
extension CalendarStaticMonthView: CalendarMonthViewProtocol {}

// MARK: - Utils

private struct WeekOffset: Equatable {
    let week: Int
    let offset: CGPoint
}

private struct WeekOffsetKey: PreferenceKey {
    static var defaultValue = WeekOffset(week: 0, offset: .zero)
    static func reduce(value: inout WeekOffset, nextValue: () -> WeekOffset) { }
}
