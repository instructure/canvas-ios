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

struct CalendarView: View {

    // MARK: Parameters

    @Binding var selectedDay: CalendarDay
    var calendarsTapped: () -> Void

    // MARK: Privates

    @State private var cardInteraction = CalendarCardInteractionState()

    // MARK: Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(yearFormatted).font(.regular12).foregroundStyle(.secondary)
                    Button {
                        withAnimation {
                            cardInteraction.isCollapsed.toggle()
                        }
                    } label: {
                        HStack {
                            Text(monthFormatted).font(.semibold22)
                            Image.chevronDown.rotationEffect(stateAngle)
                        }
                    }
                    .foregroundStyle(Color.textDarkest)
                }
                Spacer()
                Button(action: calendarsTapped) {
                    Text("Calendars", bundle: .core).font(.regular16)
                }
            }
            .padding(.horizontal)
            Spacer().frame(height: 15)
            HStack(alignment: .bottom, spacing: 0) {
                let weekdays = selectedDay.calendar.orderedWeekdays
                ForEach(weekdays, id: \.self) { weekday in
                    let name = selectedDay.calendar.shortWeekdaySymbols[weekday - 1]
                    Text(name)
                        .font(.regular12)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 5)
            Spacer().frame(height: 5)
            CalendarCardView(
                selectedDay: $selectedDay,
                interaction: $cardInteraction
            )
        }
        .padding(.vertical, 10)
        .background(Color.backgroundLightest)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: Formatted Texts

    private var yearFormatted: String {
        return selectedDay.date.formatted(
            .dateTime
            .year(.extended())
            .calendar(selectedDay.calendar)
        )
    }

    private var monthFormatted: String {
        return selectedDay.date.formatted(
            .dateTime
            .month(.wide)
            .calendar(selectedDay.calendar)
        )
    }

    // MARK: Calculation

    private var stateAngle: Angle {
        if let ratio = cardInteraction.expansionRatio {
            return .degrees(ratio * 180)
        }
        return .degrees(cardInteraction.isCollapsed ? 0 : 180)
    }
}

// MARK: - Card View

struct CalendarCardView: View {
    @Environment(\.layoutDirection) var layoutDirection

    // MARK: Properties

    @Binding var selectedDay: CalendarDay
    @Binding var interaction: CalendarCardInteractionState
    @State var periodSizes: CalendarCardPeriodViewSizes = .small

    // MARK: Body

    var body: some View {
        let height = interaction.maxHeight(for: self)
        GeometryReader { g in
            let offset = interaction.offset(for: self, given: g)
            HStack(alignment: .top, spacing: 0) {
                prevPeriodView.frame(width: g.size.width)
                currentPeriodView.frame(width: g.size.width)
                nextPeriodView.frame(width: g.size.width)
            }
            .offset(x: offset)
            .frame(maxHeight: height, alignment: .top)
            .clipped()
        }
        .frame(maxHeight: height)
        .background(Color.backgroundLightest)
        .gesture(dragGesture)
    }

    // MARK: Period Views (Pages)

    private var prevPeriodView: some View {
        CalendarPeriodView(
            collapsed: interaction.isCollapsed,
            day: interaction.prevDay(to: selectedDay)
        )
        .onCollapsableViewSized { sizes in
            periodSizes.prev = sizes.expanded
        }
    }

    private var currentPeriodView: some View {
        CalendarCurrentPeriodView(
            collapsed: interaction.isCollapsed,
            expansion: interaction.expansionRatio,
            day: $selectedDay
        )
        .onCollapsableViewSized { sizes in
            periodSizes.collapsed = sizes.collapsed
            periodSizes.current = sizes.expanded
        }
    }

    private var nextPeriodView: some View {
        CalendarPeriodView(
            collapsed: interaction.isCollapsed,
            day: interaction.nextDay(to: selectedDay)
        )
        .onCollapsableViewSized { sizes in
            periodSizes.next = sizes.expanded
        }
    }

    // MARK: Drag Gesture

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged({
                interaction.dragChanged(with: $0, in: self)
            })
            .onEnded({
                interaction.dragEnded(with: $0, in: self)
            })
    }
}

// MARK: - Period View Sizes

struct CalendarCardPeriodViewSizes {

    static var small: CalendarCardPeriodViewSizes {
        let small = CGSize(width: 100, height: 100)
        return CalendarCardPeriodViewSizes(
            collapsed: small,
            prev: small,
            current: small,
            next: small
        )
    }

    var collapsed: CGSize
    var prev: CGSize
    var current: CGSize
    var next: CGSize
}

#if DEBUG
#Preview {

    struct PreviewView: View {
        static var calendar: Calendar = {
            var calendar = Calendar(identifier: .gregorian)
            calendar.firstWeekday = 7
            return calendar
        }()

        @State var selectedDay = CalendarDay(calendar: calendar, date: .now)

        var body: some View {
            VStack {
                CalendarView(selectedDay: $selectedDay, calendarsTapped: {})
                Spacer()
            }
        }
    }
    return PreviewView()
}
#endif
