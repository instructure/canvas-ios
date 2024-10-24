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

struct CalendarWeekView: View {
    @Environment(\.plannerViewModel) var plannerModel

    @State fileprivate var dates: [Date] = []
    @Binding var calendarDay: CalendarDay

    fileprivate var week: CalendarWeek { calendarDay.week }

    var body: some View {
        Grid(horizontalSpacing: 0) {
            GridRow {
                ForEach(week.weekdays) { weekDay in
                    CalendarMonthDayView(
                        day: weekDay,
                        dots: eventsCount(for: weekDay),
                        dimsInvalidDays: false,
                        selected: calendarDay == weekDay.calendarDay
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if weekDay.isValid {
                            calendarDay = weekDay.calendarDay
                        } else {
                            withAnimation {
                                calendarDay = weekDay.calendarDay
                            }
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

struct CalendarStaticWeekView: View {
    @Environment(\.plannerViewModel) var plannerModel
    @State fileprivate var dates: [Date] = []

    let week: CalendarWeek

    var body: some View {
        Grid(horizontalSpacing: 0) {
            GridRow {
                ForEach(week.weekdays) { weekDay in
                    CalendarMonthDayView(day: weekDay, dots: eventsCount(for: weekDay))
                }
            }
        }
        .onReceive(eventDatesPublisher) { newList in
            self.dates = newList
        }
    }
}

// MARK: - Dots Fetching

private protocol CalendarWeekViewProtocol: View {
    var plannerModel: PlannerViewModelEnvironmentWrapper { get }
    var week: CalendarWeek { get }
    var dates: [Date] { get }
}

extension CalendarWeekViewProtocol {

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
                    .filter({ week.containsDate($0) })
            })
            .eraseToAnyPublisher()
    }
}

extension CalendarWeekView: CalendarWeekViewProtocol {}
extension CalendarStaticWeekView: CalendarWeekViewProtocol {}
