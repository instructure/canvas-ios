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

    @Binding var isCollapsed: Bool
    @Binding var selectedDay: CalendarDay

    private var year: String {
        return selectedDay.date.formatted(
            .dateTime(calendar: selectedDay.calendar)
            .year(.extended())
        )
    }

    private var month: String {
        return selectedDay.date.formatted(
            .dateTime(calendar: selectedDay.calendar)
            .month(.wide)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                Text(year).font(.subheadline).bold().foregroundStyle(.secondary)
                Button {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                } label: {
                    HStack {
                        Text(month).font(.title2.bold())
                        Image(systemName: "chevron.down")
                            .bold()
                            .rotationEffect(.degrees(isCollapsed ? 0 : 180))
                    }
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
            CalendarCardView(isCollapsed: $isCollapsed, selectedDay: $selectedDay)
        }
        .padding(.top, 10)
        .background(Color.backgroundLight)
    }
}

struct CalendarCardView: View {

    @Environment(\.layoutDirection) var layoutDirection

    private enum Mode {
        case stable
        case draggingHorizontal
        case completionNext
        case completionPrev
        case draggingVertical
        case collapsing
        case expanding
    }

    @State var translation: CGSize = .zero
    @State private var mode: Mode = .stable

    @State private var prevFullSize: CGSize = .small
    @State private var currentFullSize: CGSize = .small
    @State private var nextFullSize: CGSize = .small

    @State private var collapsedSize: CGSize = .small
    @State private var expansion: CGFloat?

    @Binding var isCollapsed: Bool
    @Binding var selectedDay: CalendarDay

    private let spaceID = Foundation.UUID()

    private func nextDay() -> CalendarDay {
        return isCollapsed ? selectedDay.nextWeek() : selectedDay.nextMonth()
    }

    private func prevDay() -> CalendarDay {
        return isCollapsed ? selectedDay.prevWeek() : selectedDay.prevMonth()
    }

    var body: some View {
        let height = maxHeight()
        GeometryReader { g in
            let offset = offset(given: g)
            HStack(alignment: .top, spacing: 0) {
                prevPeriodView.frame(width: g.size.width)
                currentPeriodView.frame(width: g.size.width)
                nextPeriodView.frame(width: g.size.width)
            }
            .offset(x: offset)
            .frame(maxHeight: height, alignment: .top)
            .clipped()
            .coordinateSpace(name: spaceID)
        }
        .frame(maxHeight: height)
        .background(Color(uiColor: .secondarySystemBackground))
        .gesture(dragGesture)
    }

    private var prevPeriodView: some View {
        CalendarPeriodView(collapsed: isCollapsed, day: prevDay())
            .onCollapsableViewSized { sizes in
                prevFullSize = sizes.expanded
            }
    }

    private var currentPeriodView: some View {
        CalendarCurrentPeriodView(
            collapsed: isCollapsed,
            expansion: expansion,
            day: $selectedDay
        )
        .onCollapsableViewSized { sizes in
            collapsedSize = sizes.collapsed
            currentFullSize = sizes.expanded
        }
    }

    private var nextPeriodView: some View {
        CalendarPeriodView(collapsed: isCollapsed, day: nextDay())
            .onCollapsableViewSized { sizes in
                nextFullSize = sizes.expanded
            }
    }

    private func offset(given g: GeometryProxy) -> CGFloat {
        switch mode {
        case .completionNext:
            return -2 * g.size.width
        case .completionPrev:
            return 0
        case .draggingHorizontal:
            return layoutDirection == .rightToLeft
                ? -1 * translation.width - g.size.width
                : translation.width - g.size.width
        default:
            return -1 * g.size.width
        }
    }

    private func maxHeight() -> CGFloat {
        switch mode {
        case .collapsing:
            return collapsedSize.height
        case .expanding:
            return currentFullSize.height
        case .draggingVertical:
            let base = isCollapsed ? collapsedSize.height : currentFullSize.height
            return max(collapsedSize.height, min(base + translation.height, currentFullSize.height))
        case .draggingHorizontal where isCollapsed == false:
            let targetHeight = (isTranslationForward ? nextFullSize : prevFullSize).height
            return max(targetHeight, currentFullSize.height)
        case .completionNext where isCollapsed == false:
            return nextFullSize.height
        case .completionPrev where isCollapsed == false:
            return prevFullSize.height
        default:
            return isCollapsed ? collapsedSize.height : currentFullSize.height
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged({ value in
                translation = value.translation

                if case .stable = mode {
                    let velocity = value.velocity
                    mode = abs(velocity.height) > abs(velocity.width) ? .draggingVertical : .draggingHorizontal
                }

                if case .draggingVertical = mode {
                    let base = isCollapsed ? collapsedSize.height : currentFullSize.height
                    let maxHeight = base + translation.height
                    let dh = (maxHeight - collapsedSize.height) / (currentFullSize.height - collapsedSize.height)
                    expansion = min(max(dh, 0), 1)
                } else {
                    expansion = nil
                }
            })
            .onEnded({ value in

                switch mode {
                case .draggingHorizontal:

                    let shouldSwitch = abs(translation.width) / currentFullSize.width > 0.4 || abs(value.velocity.width) > 30
                    let increment: Mode = isTranslationForward ? .completionNext : .completionPrev

                    withAnimation(duration: 0.4) {
                        mode = shouldSwitch ? increment : .stable
                    } completion: {
                        guard shouldSwitch else { return }

                        if case .completionNext = increment {
                            selectedDay = nextDay()
                        } else if case .completionPrev = increment {
                            selectedDay = prevDay()
                        }

                        mode = .stable
                        translation = .zero
                        expansion = nil
                    }

                case .draggingVertical:

                    let shouldCollapse = abs(translation.height) / currentFullSize.height > 0.4 || abs(value.velocity.height) > 30
                    let increment: Mode = translation.height < 0 ? .collapsing : .expanding

                    withAnimation(duration: 0.4) {
                        mode = shouldCollapse ? increment : .stable
                        expansion = shouldCollapse ? (increment == .collapsing ? 0 : 1) : nil
                    } completion: {
                        guard shouldCollapse else { return }

                        isCollapsed = increment == .collapsing ? true : false
                        mode = .stable
                        translation = .zero
                        expansion = nil
                    }

                default: break
                }
            })
    }

    private var isTranslationForward: Bool {
        return translation.isForward(layoutDirection)
    }
}

extension CGSize {
    func isForward(_ layoutDirection: LayoutDirection) -> Bool {
        switch layoutDirection {
        case .rightToLeft:
            return width >= 0
        default:
            return width < 0
        }
    }
}

#Preview {

    struct PreviewView: View {
        static var calendar: Calendar = {
            var calendar = Calendar(identifier: .gregorian)
            calendar.firstWeekday = 7
            return calendar
        }()

        @State var isCollapsed: Bool = false
        @State var selectedDay = CalendarDay(calendar: calendar, date: .now)

        var body: some View {
            VStack {
                CalendarView(isCollapsed: $isCollapsed, selectedDay: $selectedDay)
                Spacer()
            }
        }
    }
    return PreviewView()
}
