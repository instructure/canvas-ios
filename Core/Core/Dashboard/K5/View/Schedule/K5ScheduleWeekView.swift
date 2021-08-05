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
    private let viewModel: K5ScheduleWeekViewModel

    public init(viewModel: K5ScheduleWeekViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        CompatibleScrollViewReader { proxy in
            List {
                let dayModels = viewModel.days
                ForEach(dayModels) { dayModel in
                    Section(header: header(for: dayModel)) {
                        VStack(spacing: 24) {
                            if dayModel.subjects.isEmpty {
                                nothingPlannedView
                            } else {
                                ForEach(dayModel.subjects) { subjectModel in
                                    K5ScheduleSubjectView(viewModel: subjectModel)
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: horizontalPadding, bottom: 0, trailing: horizontalPadding))
                        .padding(.bottom, dayModels.last == dayModel ? 24 : 0)
                    }
                    .id(dayModel.weekday)
                }
            }
            // This adds some extra space on top but without this the content
            // scrolls below the sticky section header. clipped() clips the
            // section header's top for some reason so we can't use that.
            .padding(.top, 1)
            .onAppear(perform: {
                proxy.scrollTo(viewModel.todayViewId, anchor: .top)
            })
            .overlay(todayButton(scrollProxy: proxy), alignment: .topTrailing)
        }
    }

    private func todayButton(scrollProxy: CompatibleScrollViewProxy) -> some View {
        Button(action: {
            withAnimation {
                scrollProxy.scrollTo(viewModel.todayViewId, anchor: .top)
            }
        }, label: {
            Text("Today", bundle: .core)
                .font(.regular17)
                .foregroundColor(Color(Brand.shared.primary))
                .padding(.trailing, horizontalPadding)
                .padding(.top, 55)
        })
        .hidden(!viewModel.isTodayButtonAvailable)
    }

    private func header(for model: K5ScheduleDayViewModel) -> some View {
        let content = VStack(alignment: .leading) {
            Text(model.weekday)
                .font(.bold24)
            Text(model.date)
                .font(.bold17)
        }
        .foregroundColor(.licorice)
        .padding(.top, 26)
        .padding(.leading, horizontalPadding)

        let background = Rectangle()
            .fill(Color.white)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .frame(minHeight: 93)

        return background.overlay(content, alignment: .topLeading)
    }

    private var nothingPlannedView: some View {
        Text("Nothing planned yet", bundle: .core)
            .font(.regular17)
            .foregroundColor(.licorice)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 6).stroke(Color.tiara, lineWidth: 4))
            .cornerRadius(3)
    }
}

#if DEBUG

struct K5ScheduleWeekView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        K5ScheduleWeekView(viewModel: K5Preview.Data.Schedule.weeks[0])
        K5ScheduleWeekView(viewModel: K5Preview.Data.Schedule.weeks[1])

        K5ScheduleWeekView(viewModel: K5Preview.Data.Schedule.weeks[0])
            .previewDevice(PreviewDevice(stringLiteral: "iPad (8th generation)"))
            .environment(\.containerSize, CGSize(width: 500, height: 0))
    }
}

#endif
