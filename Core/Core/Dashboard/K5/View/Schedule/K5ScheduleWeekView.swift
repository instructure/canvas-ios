//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct K5ScheduleWeekView: View {
    @Environment(\.containerSize) private var containerSize
    @Environment(\.horizontalPadding) private var horizontalPadding
    private var isCompact: Bool { containerSize.width < 500 }
    @ObservedObject private var viewModel: K5ScheduleWeekViewModel
    // In case this isn't the current week we don't update this variable so the Today button will be always visible
    @State private var isTodayCellVisible = false
    @State private var didAppear = false
    private let todayPressed: () -> Void

    public init(viewModel: K5ScheduleWeekViewModel, todayPressed: @escaping () -> Void) {
        self.viewModel = viewModel
        self.todayPressed = todayPressed
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                List {
                    let dayModels = viewModel.days
                    ForEach(dayModels) { dayModel in
                        let isLastDay = dayModels.last == dayModel
                        let isToday = viewModel.isTodayModel(dayModel)
                        dayCell(for: dayModel, isLastDay: isLastDay, isToday: isToday, geometry: geometry)
                            .listRowBackground(Color.backgroundLightest)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                // This removes the gray highlight from list items on tap
                .buttonStyle(.borderless)
                // This adds some extra space on top but without this the content
                // scrolls below the sticky section header. clipped() clips the
                // section header's top for some reason so we can't use that.
                .padding(.top, 1)
                .onAppear(perform: {
                    if didAppear { return }

                    DispatchQueue.main.async {
                        scrollProxy.scrollTo(viewModel.todayViewId, anchor: .top)
                        viewModel.viewDidAppear()
                        didAppear = true
                    }
                })
                .overlay(todayButton(scrollProxy: scrollProxy), alignment: .topTrailing)
                .onPreferenceChange(ViewBoundsKey.self, perform: { value in
                    guard let frame = value.first?.bounds else { return }
                    todayHeaderPositionDidUpdate(frame, in: geometry)
                })
            }
        }
    }

    private func dayCell(for dayModel: K5ScheduleDayViewModel, isLastDay: Bool, isToday: Bool, geometry: GeometryProxy) -> some View {
        let header = header(for: dayModel, isToday: isToday, geometry: geometry)
        let body = K5ScheduleDayView(viewModel: dayModel)
            .listRowInsets(EdgeInsets(top: 0, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding))
            .padding(.bottom, isLastDay ? 24 : 0)
        let section = Section(header: header) { body }
            .id(dayModel.weekday)

        return section
    }

    private func todayButton(scrollProxy: ScrollViewProxy) -> some View {
        Button(action: {
            withAnimation {
                scrollProxy.scrollTo(viewModel.todayViewId, anchor: .top)
            }
            todayPressed()
        }, label: {
            Text("Today", bundle: .core)
                .font(.regular17)
                .foregroundColor(Color(Brand.shared.primary))
                .padding(.trailing, horizontalPadding)
                .padding(.top, 55)
        })
        .hidden(isTodayCellVisible)
    }

    @ViewBuilder
    private func header(for model: K5ScheduleDayViewModel, isToday: Bool, geometry: GeometryProxy) -> some View {
        let content = VStack(alignment: .leading) {
            Text(model.weekday).font(.bold24).textCase(nil)
            Text(model.date).font(.bold17).textCase(nil)
        }
        .foregroundColor(.textDarkest)
        .padding(.top, 26)
        .padding(.leading, horizontalPadding)

        let background = Rectangle()
            .fill(Color.backgroundLightest)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .frame(minHeight: 93)
        let header = background
            .overlay(content, alignment: .topLeading)
            .accessibilityElement(children: .combine)

        if isToday {
            header
                // Save the frame of the today header cell so we can inspect its changes and show/hide the today button based on its value
                .transformAnchorPreference(key: ViewBoundsKey.self, value: .bounds) { preferences, bounds in
                    preferences = [.init(viewId: 0, bounds: geometry[bounds])]
                }
        } else {
            header
        }
    }

    private func todayHeaderPositionDidUpdate(_ frame: CGRect, in geometry: GeometryProxy) {
        // Constants are to offset paddings of the Today label so when the label goes out of screen we can show the Today button instantly
        let isScrolledOutOnTop = frame.maxY - 20 <= 0
        let isScrolledOutOnBottom = frame.minY + 30 > geometry.size.height
        let isTodayCellVisible = !(isScrolledOutOnTop || isScrolledOutOnBottom)

        guard self.isTodayCellVisible != isTodayCellVisible else { return }

        // If we animate the today button during the first render cycle it causes glitches in List Section headers.
        if didAppear {
            withAnimation {
                self.isTodayCellVisible = isTodayCellVisible
            }
        } else {
            self.isTodayCellVisible = isTodayCellVisible
        }
    }
}

#if DEBUG

struct K5ScheduleWeekView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        K5ScheduleWeekView(viewModel: K5Preview.Data.Schedule.weeks[0], todayPressed: {})
        K5ScheduleWeekView(viewModel: K5Preview.Data.Schedule.weeks[1], todayPressed: {})

        K5ScheduleWeekView(viewModel: K5Preview.Data.Schedule.weeks[0], todayPressed: {})
            .previewDevice(PreviewDevice(stringLiteral: "iPad (9th generation)"))
            .environment(\.containerSize, CGSize(width: 500, height: 0))
    }
}

#endif
