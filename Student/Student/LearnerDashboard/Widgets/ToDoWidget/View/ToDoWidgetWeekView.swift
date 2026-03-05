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

import Combine
import Core
import SwiftUI

struct ToDoWeekPageView: View {
    let weekDays: [Date]
    let viewModel: ToDoWidgetViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                ToDoWidgetDayCell(
                    date: day,
                    isSelected: Calendar.current.isDate(day, inSameDayAs: viewModel.selectedDay),
                    isToday: Calendar.current.isDateInToday(day),
                    itemCount: viewModel.itemCounts[day, default: 0]
                )
                .onTapGesture { viewModel.selectDay(day) }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct ToDoWidgetDayCell: View {
    @ScaledMetric private var uiScale: CGFloat = 1

    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let itemCount: Int

    var body: some View {
        VStack(spacing: 0) {
            Text(date.weekdayNameAbbreviated)
                .font(.regular12, lineHeight: .fit)
                .foregroundStyle(labelColor)

            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.accentColor)
                } else if isToday {
                    Circle()
                        .stroke(Color.accentColor)
                }

                Text(date.dayString)
                    .font(isSelected || isToday ? .bold12 : .regular12, lineHeight: .fit)
                    .foregroundStyle(isSelected ? Color.textLightest : labelColor)
            }
            .scaledFrame(size: 32, useIconScale: true)
            .padding(.top, 2)

            HStack(spacing: 3) {
                ForEach(0..<min(itemCount, 3), id: \.self) { _ in
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 4 * uiScale, height: 4 * uiScale)
                }
            }
            .frame(height: 4 * uiScale)
            .padding(.top, 3)
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
        let dateLabel = date.formatted(.dateTime.weekday(.wide).month(.wide).day())
        if itemCount == 0 {
            return dateLabel
        }
        return "\(dateLabel), \(itemCount) \(String(localized: "items", bundle: .core))"
    }
}

#if DEBUG

#Preview("Current week") {
    ToDoWeekPageView(
        weekDays: (0..<7).compactMap {
            Calendar.current.date(byAdding: .day, value: $0, to: ToDoWidgetViewModel.startOfWeek(for: Clock.now))
        },
        viewModel: ToDoWidgetViewModel(
            config: DashboardWidgetConfig(id: .toDo, order: 0, isVisible: true, settings: nil),
            interactor: TodoInteractorPreview(),
            router: AppEnvironment.shared.router,
            snackBarViewModel: SnackBarViewModel()
        )
    )
    .padding()
}

#Preview("Individual day cells") {
    let today = Clock.now
    HStack(spacing: 0) {
        ToDoWidgetDayCell(date: today, isSelected: false, isToday: false, itemCount: 0)
            .frame(maxWidth: .infinity)
        ToDoWidgetDayCell(date: today, isSelected: false, isToday: true, itemCount: 2)
            .frame(maxWidth: .infinity)
        ToDoWidgetDayCell(date: today, isSelected: true, isToday: false, itemCount: 3)
            .frame(maxWidth: .infinity)
        ToDoWidgetDayCell(date: today, isSelected: true, isToday: true, itemCount: 1)
            .frame(maxWidth: .infinity)
    }
    .padding()
}

#endif
