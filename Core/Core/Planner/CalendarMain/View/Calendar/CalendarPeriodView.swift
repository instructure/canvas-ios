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

struct CalendarCurrentPeriodView: View {
    let collapsed: Bool
    let expansion: CGFloat?

    @Binding var day: CalendarDay

    init(collapsed: Bool,
         expansion: CGFloat?,
         day: Binding<CalendarDay>) {

        self.collapsed = collapsed
        self.expansion = expansion
        self._day = day
    }

    @State private var fullSize: CGSize = .zero
    @State private var collapsedSize: CGSize = .zero
    @State private var offsets = [Int: CGFloat]()

    private var selectedOffset: CGFloat {
        let min = offsets.values.min() ?? 0
        let val = offsets[day.week.weekOfMonth] ?? 0
        return val - min
    }

    private var expandedOpacity: CGFloat {
        return expansion ?? (collapsed ? 0 : 1)
    }

    private var collapsedOpacity: CGFloat {
        return expansion.flatMap({ 1 - $0 }) ?? (collapsed ? 1 : 0)
    }

    var body: some View {
        ZStack(alignment: .top) {
            CalendarMonthView(calendarDay: $day, offsets: $offsets)
                .padding(5)
                .measuringSize($fullSize)
                .opacity(expandedOpacity)
                .offset(y: -1 * collapsedOpacity * selectedOffset)

            CalendarWeekView(calendarDay: $day)
                .padding(5)
                .measuringSizeOnce($collapsedSize)
                .opacity(ceil(collapsedOpacity))
                .offset(y: expandedOpacity * selectedOffset)
        }
        .preferredCollapsableViewSize(
            collapsed: collapsedSize,
            expanded: fullSize
        )
    }
}

struct CalendarPeriodView: View {
    let collapsed: Bool
    let day: CalendarDay

    @State private var fullSize: CGSize = .zero

    init(collapsed: Bool, day: CalendarDay) {
        self.collapsed = collapsed
        self.day = day
    }

    var body: some View {
        ZStack(alignment: .top) {
            CalendarStaticMonthView(month: day.month)
                .padding(5)
                .measuringSize($fullSize)
                .opacity(collapsed ? 0 : 1)
            CalendarStaticWeekView(week: day.week)
                .padding(5)
                .opacity(collapsed ? 1 : 0)
        }
        .preferredCollapsableViewSize(
            collapsed: .zero,
            expanded: fullSize
        )
        .animation(nil, value: collapsed)
    }
}

#Preview {
    struct PreviewView: View {
        @State var selectedDay = CalendarDay(calendar: .current, date: .now)
        @State var isCollapsed: Bool = false

        var body: some View {
            CalendarView(isCollapsed: $isCollapsed, selectedDay: $selectedDay)
        }
    }
    return PreviewView()
}
