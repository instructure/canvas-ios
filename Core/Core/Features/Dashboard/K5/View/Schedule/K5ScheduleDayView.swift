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

public struct K5ScheduleDayView: View {
    @ObservedObject private var viewModel: K5ScheduleDayViewModel

    public init(viewModel: K5ScheduleDayViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 24) {
            switch (viewModel.subjects) {
            case .empty:
                nothingPlannedView
                missingItemsView
            case .loading:
                loadingView
            case .data(let subjects):
                ForEach(subjects) { subjectModel in
                    K5ScheduleSubjectView(viewModel: subjectModel)
                }
                missingItemsView
            }
        }.background(Color.backgroundLightest)
    }

    private var nothingPlannedView: some View {
        Text("Nothing planned yet", bundle: .core)
            .font(.regular17)
            .foregroundColor(.textDarkest)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 6).stroke(Color.backgroundMedium, lineWidth: 4))
            .cornerRadius(3)
    }

    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(.indeterminateCircle(size: 55))
            .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var missingItemsView: some View {
        if !viewModel.missingItems.isEmpty {
            K5ScheduleMissingItemsView(missingItems: viewModel.missingItems)
        }
    }
}

#if DEBUG

struct K5ScheduleDayView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        K5ScheduleDayView(viewModel: K5Preview.Data.Schedule.weeks[0].days[1])
        K5ScheduleDayView(viewModel: K5Preview.Data.Schedule.weeks[1].days[0])
        K5ScheduleDayView(viewModel: K5Preview.Data.Schedule.weeks[1].days[1])

        K5ScheduleDayView(viewModel: K5Preview.Data.Schedule.weeks[0].days[1])
            .previewDevice(PreviewDevice(stringLiteral: "iPad (9th generation)"))
            .environment(\.containerSize, CGSize(width: 500, height: 0))
        K5ScheduleDayView(viewModel: K5Preview.Data.Schedule.weeks[1].days[0])
            .previewDevice(PreviewDevice(stringLiteral: "iPad (9th generation)"))
            .environment(\.containerSize, CGSize(width: 500, height: 0))
        K5ScheduleDayView(viewModel: K5Preview.Data.Schedule.weeks[1].days[1])
            .previewDevice(PreviewDevice(stringLiteral: "iPad (9th generation)"))
            .environment(\.containerSize, CGSize(width: 500, height: 0))
    }
}

#endif
