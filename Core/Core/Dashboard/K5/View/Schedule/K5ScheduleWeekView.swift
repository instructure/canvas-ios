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
    // If we animate the today button during the first render cycle it causes glitches in List Section headers.
    @State private var didAppear = false
    private let todayPressed: () -> Void

    public init(viewModel: K5ScheduleWeekViewModel, todayPressed: @escaping () -> Void) {
        self.viewModel = viewModel
        self.todayPressed = todayPressed
    }

    public var body: some View {
        CompatibleScrollViewReader { scrollProxy in
            List {
                let dayModels = viewModel.days
                ForEach(dayModels) { dayModel in
                    dayCell(for: dayModel, isLastDay: dayModels.last == dayModel)
                }
            }
            // This removes the gray highlight from list items on tap
            .buttonStyle(BorderlessButtonStyle())
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
        }
    }

    @ViewBuilder
    private func dayCell(for dayModel: K5ScheduleDayViewModel, isLastDay: Bool) -> some View {
        let section = Section(header: header(for: dayModel)) {
            K5ScheduleDayView(viewModel: dayModel)
                .listRowInsets(EdgeInsets(top: 0, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding))
                .padding(.bottom, isLastDay ? 24 : 0)
        }
        .id(dayModel.weekday)

        if viewModel.isTodayModel(dayModel) {
            section
                .onAppear {
                    setTodayCellVisible(to: true)
                }
                .onDisappear {
                    setTodayCellVisible(to: false)
                }
        } else {
            section
        }
    }

    private func todayButton(scrollProxy: CompatibleScrollViewProxy) -> some View {
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

    private func header(for model: K5ScheduleDayViewModel) -> some View {
        let content = VStack(alignment: .leading) {
            let weekday = Text(model.weekday).font(.bold24)
            let date = Text(model.date).font(.bold17)

            if #available(iOS 14, *) {
                weekday.textCase(nil)
                date.textCase(nil)
            } else {
                weekday
                date
            }
        }
        .foregroundColor(.licorice)
        .padding(.top, 26)
        .padding(.leading, horizontalPadding)

        let background = Rectangle()
            .fill(Color.white)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .frame(minHeight: 93)

        return background.overlay(content, alignment: .topLeading).accessibilityElement(children: .combine)
    }

    private func setTodayCellVisible(to isVisible: Bool) {
        if didAppear {
            withAnimation {
                isTodayCellVisible = isVisible
            }
        } else {
            isTodayCellVisible = isVisible
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
            .previewDevice(PreviewDevice(stringLiteral: "iPad (8th generation)"))
            .environment(\.containerSize, CGSize(width: 500, height: 0))
    }
}

#endif
