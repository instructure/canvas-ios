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

import SwiftUI
import Core
import WidgetKit

struct TodoDayView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var uiScale: CGFloat = 1

    let date: Date

    var body: some View {
        Link(destination: .calendarDayRoute(date)) {
            VStack(spacing: 0) {
                Text(date.formatted(.dateTime.weekday()))
                    .font(.regular12)
                    .foregroundStyle(isToday ? .course2 : .textDark)

                Text(date.formatted(.dateTime.day()))
                    .font(.bold12)
                    .foregroundStyle(isToday ? .course2 : .textDark)
                    .padding(.vertical, isToday ? 13 : 4)
                    .frame(minWidth: 32)
                    .overlay {
                        if isToday {
                            Circle()
                                .stroke(.course2, style: .init(lineWidth: 1))
                        }
                    }
            }
        }
        .accessibilityElement()
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(
            (isToday ? String(localized: "Today, ") : "") +
            date.formatted(.dateTime.weekday(.wide).month(.wide).day())
        )
    }

    private var isToday: Bool {
        return date.startOfDay() == Date.now.startOfDay()
    }
}

#if DEBUG

#Preview("TodoWidgetData", as: .systemLarge) {
    TodoWidget()
} timeline: {
    TodoWidgetEntry(data: TodoModel.make(), date: Date())
}

#endif
