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
    let date: Date

    var body: some View {
        Link(destination: .calendarDayRoute(date)) {
            VStack(spacing: 3) {
                Text(date.formatted(.dateTime.weekday()))
                    .font(.regular12)
                    .foregroundStyle(isToday ? .course2 : .textDark)
                ZStack {
                    if isToday {
                        Circle()
                            .fill(.background)
                            .stroke(.course2, style: .init(lineWidth: 1))
                            .frame(width: 30, height: 30)
                    }
                    Text(date.formatted(.dateTime.day()))
                        .font(.bold12)
                        .foregroundStyle(isToday ? .course2 : .textDark)
                }
            }
        }
        .frame(minWidth: 34)
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

#Preview {
    TodoDayView(date: Date())
    TodoDayView(date: Date().addDays(4))
}

#endif
