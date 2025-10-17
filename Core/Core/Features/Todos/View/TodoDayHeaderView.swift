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

struct TodoDayHeaderView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric private var uiScale: CGFloat = 1

    let group: TodoGroupViewModel
    let onTap: (TodoGroupViewModel) -> Void
    let tintColor: Color

    init(group: TodoGroupViewModel, onTap: @escaping (TodoGroupViewModel) -> Void) {
        self.group = group
        self.onTap = onTap
        self.tintColor = group.isToday ? Color.accentColor : .textDark
    }

    var body: some View {
        Button {
            onTap(group)
        } label: {
            VStack(spacing: 0) {
                Text(group.weekdayAbbreviation)
                    .font(.regular12, lineHeight: .fit)
                ZStack {
                    Circle()
                        .stroke(tintColor)
                        .scaledFrame(size: 32, useIconScale: true)
                        .hidden(!group.isToday)
                    Text(group.dayNumber)
                        .font(group.isToday ? .bold12 : .regular12, lineHeight: .fit)
                        .padding(.top, group.isToday ? 0 : uiScale * -14)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 9) // to maximize hit area
            .frame(width: Self.headerWidth(uiScale), alignment: .center)
            .foregroundStyle(tintColor)
            .contentShape(Rectangle())
        }
        .background(Color.backgroundLightest)
        .buttonStyle(.plain)
        .accessibilityLabel(group.accessibilityLabel)
        .accessibilityAddTraits(.isHeader)
    }

    static func headerWidth(_ uiScale: CGFloat) -> CGFloat {
        64 * uiScale.todoHeaderWidthScale
    }
}

private extension CGFloat {

    var todoHeaderWidthScale: CGFloat {
        if self > 1 {
            return 1 + 0.2 * (self - 1)
        } else {
            return self
        }
    }
}

#if DEBUG

#Preview {
    let today = Calendar.current.startOfDay(for: Date())
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    let todayGroup = TodoGroupViewModel(
        date: today,
        items: [.makeShortText(id: "1")]
    )
    let tomorrowGroup = TodoGroupViewModel(
        date: tomorrow,
        items: [.makeShortText(id: "1")]
    )

    HStack(spacing: 0) {
        TodoDayHeaderView(group: todayGroup) { _ in }
        TodoDayHeaderView(group: tomorrowGroup) { _ in }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.backgroundDarkest)
    .tint(.course1)
}

#endif
