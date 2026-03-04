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
    let showCompleted: Bool
    let onPreviousWeek: () -> Void
    let onNextWeek: () -> Void
    let onSelectDay: (Date) -> Void
    let onToggleShowCompleted: () -> Void

    private var weekDays: [Date] {
        (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: weekStart)
        }
    }

    private var isCurrentYear: Bool {
        Calendar.current.isDate(selectedDay, equalTo: Clock.now, toGranularity: .year)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerRow
                .paddingStyle(.horizontal, .standard)
                .padding(.bottom, 4)
            showCompletedRow
                .paddingStyle(.horizontal, .standard)
                .padding(.bottom, 8)
            calendarRow
        }
        .padding(.vertical, 8)
    }

    private var headerRow: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                if !isCurrentYear {
                    Text(selectedDay.formatted(.dateTime.year()))
                        .font(.regular12, lineHeight: .fit)
                        .foregroundStyle(Color.textDark)
                }
                Text(selectedDay.formatted(.dateTime.month(.wide)))
                    .font(.semibold22)
                    .foregroundStyle(Color.textDarkest)
            }
            Spacer()
        }
    }

    private var showCompletedRow: some View {
        let binding = Binding<Bool>(
            get: { showCompleted },
            set: { _ in onToggleShowCompleted() }
        )
        return InstUI.Toggle(isOn: binding) {
            Text("Show completed", bundle: .core)
                .font(.regular14)
                .foregroundStyle(Color.textDark)
        }
    }

    private var calendarRow: some View {
        ZStack {
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

            HStack {
                circleNavButton(
                    systemImage: "chevron.left",
                    a11yLabel: String(localized: "Previous week", bundle: .student),
                    action: onPreviousWeek
                )
                Spacer()
                circleNavButton(
                    systemImage: "chevron.right",
                    a11yLabel: String(localized: "Next week", bundle: .student),
                    action: onNextWeek
                )
            }
            .paddingStyle(.horizontal, .standard)
        }
    }

    private func circleNavButton(systemImage: String, a11yLabel: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.textLightest)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.accentColor))
        }
        .accessibilityLabel(a11yLabel)
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
