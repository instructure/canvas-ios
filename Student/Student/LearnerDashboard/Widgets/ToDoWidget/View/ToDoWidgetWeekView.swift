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
    let weekDays: [Date]
    let viewModel: ToDoWidgetViewModel

    @AccessibilityFocusState private var isDayFocused

    var body: some View {
        ViewThatFits(in: .horizontal) {
            content(isCompact: false)
            content(isCompact: true)
        }
    }

    private func content(isCompact: Bool) -> some View {
        HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { day in
                Button {
                    viewModel.didTapDay(day)
                } label: {
                    ToDoWidgetDayCell(
                        date: day,
                        isSelected: day.isInSameDay(as: viewModel.selectedDay),
                        isToday: day.isToday,
                        itemCount: viewModel.itemCountPerDay[day] ?? 0,
                        isCompact: isCompact
                    )
                    .accessibilityFocused($isDayFocused, when: Date.now.isInSameDay(as: day))
                }
                .frame(maxWidth: .infinity)
                .identifier("Dashboard.Todo.dayButton")
            }
        }
        .onChange(of: viewModel.isTodayFocused) {
            isDayFocused = true
        }
    }
}

private struct ToDoWidgetDayCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let itemCount: Int
    var isCompact: Bool

    var body: some View {
        VStack(spacing: 0) {
            weekdayLabel
                .padding(.bottom, 6)
            dayNumberView
            dotsView
                .padding(.top, -2)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }

    private var weekdayLabel: some View {
        Text(date.formatted(.dateTime.weekday(isCompact ? .narrow : .abbreviated)))
            .font(.regular12, lineHeight: .fit)
            .foregroundStyle(.textDarkest)
    }

    private var dayNumberView: some View {
        ZStack {
            if isSelected {
                Circle()
                    .fill(.tint)
            }
            Text(date.dayString)
                .font(.regular16, lineHeight: .fit)
                .foregroundStyle(dayNumberForegroundStyle)
        }
        .scaledFrame(size: 32, useIconScale: true)
    }

    private var dayNumberForegroundStyle: some ShapeStyle {
        if isSelected {
            AnyShapeStyle(.textLightest)
        } else if isToday {
            AnyShapeStyle(.tint)
        } else {
            AnyShapeStyle(.textDarkest)
        }
    }

    @ViewBuilder
    private var dotsView: some View {
        let dotCount = isSelected ? 0 : min(itemCount, 3)

        HStack(spacing: 6) {
            ForEach(0..<dotCount, id: \.self) { _ in
                Circle()
                    .fill(.tint)
            }
        }
        .scaledFrame(height: 4)
    }

    private var accessibilityLabel: String {
        [
            date.formatted(.dateTime.weekday(.wide).month(.wide).day()),
            itemCount > 0 ? String.format(numberOfItems: itemCount) : nil
        ].accessibilityJoined()
    }
}

#if DEBUG

#Preview("Current week") {
    let date = Clock.now

    PreviewContainer(horizontalPadding: 16) {
        ToDoWidgetWeekView(
            weekDays: (0..<7).compactMap { date.addDays($0) },
            viewModel: ToDoWidgetViewModel(
                config: .make(id: .todo),
                interactor: TodoInteractorPreview(),
                router: AppEnvironment.shared.router,
                snackBarViewModel: SnackBarViewModel()
            )
        )
    }
}

#Preview("Individual day cells") {
    let today = Clock.now

    PreviewContainer {
        HStack(spacing: 20) {
            ToDoWidgetDayCell(date: today, isSelected: false, isToday: false, itemCount: 0, isCompact: false)
            ToDoWidgetDayCell(date: today, isSelected: false, isToday: false, itemCount: 42, isCompact: false)
            ToDoWidgetDayCell(date: today, isSelected: false, isToday: true, itemCount: 2, isCompact: false)
            ToDoWidgetDayCell(date: today, isSelected: true, isToday: false, itemCount: 3, isCompact: false)
            ToDoWidgetDayCell(date: today, isSelected: true, isToday: true, itemCount: 1, isCompact: false)
            ToDoWidgetDayCell(date: today, isSelected: true, isToday: true, itemCount: 1, isCompact: true)
        }
    }
}

#endif
