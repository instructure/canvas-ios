//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core
import SwiftUI

struct ToDoWidgetWeekView: View {
    let selectedDay: Date
    let weekStart: Date
    let datesWithItems: Set<Date>
    let isShowingCurrentWeek: Bool
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void
    let onToday: () -> Void
    let onSelectDay: (Date) -> Void

    private var weekDays: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: weekStart)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerRow
            dayRow
        }
        .padding(.vertical, 8)
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Button(action: onPreviousWeek) {
                Image.huiIcons.chevronLeft
                    .scaledIcon(size: 20)
                    .padding(8)
            }
            .foregroundStyle(Color.textDark)
            .accessibilityLabel(String(localized: "Previous week", bundle: .student))

            Text(monthYearText)
                .font(.semibold16)
                .foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity)

            if !isShowingCurrentWeek {
                Button(String(localized: "Today", bundle: .core), action: onToday)
                    .font(.regular14)
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 8)
            }

            Button(action: onNextWeek) {
                Image.chevronRight
                    .scaledIcon(size: 20)
                    .padding(8)
            }
            .foregroundStyle(Color.textDark)
            .accessibilityLabel(String(localized: "Next week", bundle: .student))
        }
        .paddingStyle(.horizontal, .standard)
    }

    private var dayRow: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                ToDoWidgetDayCell(
                    date: day,
                    isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDay),
                    isToday: Calendar.current.isDateInToday(day),
                    hasItems: datesWithItems.contains(day)
                )
                .onTapGesture { onSelectDay(day) }
                .frame(maxWidth: .infinity)
            }
        }
        .paddingStyle(.horizontal, .standard)
    }

    private var monthYearText: String {
        selectedDay.formatted(.dateTime.month(.wide).year())
    }
}

private struct ToDoWidgetDayCell: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasItems: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(date.weekdayNameAbbreviated)
                .font(.regular12, lineHeight: .fit)
                .foregroundStyle(labelColor)

            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.accentColor)
                        .scaledFrame(size: 32, useIconScale: true)
                } else if isToday {
                    Circle()
                        .stroke(Color.accentColor)
                        .scaledFrame(size: 32, useIconScale: true)
                }

                Text(date.dayString)
                    .font(isSelected || isToday ? .bold12 : .regular12, lineHeight: .fit)
                    .foregroundStyle(isSelected ? Color.textLightest : labelColor)
            }
            .padding(.top, 2)

            Circle()
                .fill(Color.accentColor)
                .frame(width: 4 * uiScale, height: 4 * uiScale)
                .padding(.top, 3)
                .opacity(hasItems ? 1 : 0)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var labelColor: Color {
        isToday ? Color.accentColor : .textDark
    }

    private var accessibilityLabel: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}
