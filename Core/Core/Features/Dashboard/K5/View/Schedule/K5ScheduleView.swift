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

public struct K5ScheduleView: View, ScreenViewTrackable {
    @ObservedObject var viewModel: K5ScheduleViewModel
    @Environment(\.horizontalPadding) private var horizontalPadding
    public let screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "/schedule")

    @State private var currentPageIndex: Int = 0
    @State private var pagerProxy = HorizontalPagerProxy()
    private let animation = Animation.easeOut(duration: 0.2)

    public var body: some View {
        VStack(spacing: 0) {
            HorizontalPager(pageCount: viewModel.weekModels.count,
                            initialPageIndex: viewModel.defaultWeekIndex,
                            currentPageIndex: $currentPageIndex.animation(animation),
                            pagerProxy: pagerProxy) { pageIndex in
                K5ScheduleWeekView(viewModel: viewModel.weekModels[pageIndex], todayPressed: {
                    pagerProxy.scrollToPage(viewModel.defaultWeekIndex, animated: true)
                })
            }
            Divider()
            pageSwitcherButtons
        }
    }

    private var pageSwitcherButtons: some View {
        HStack(spacing: 0) {
            Button(action: pagerProxy.scrollToPreviousPage) {
                HStack(spacing: 0) {
                    Image.miniArrowStartSolid
                    Text("Previous Week", bundle: .core)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, horizontalPadding - 7) // -7 to offset the arrow's burnt in padding
            .padding(.trailing, 16)
            .hidden(viewModel.isOnFirstPage(currentPageIndex: currentPageIndex))

            Spacer()

            Button(action: pagerProxy.scrollToNextPage) {
                HStack(spacing: 0) {
                    Text("Next Week", bundle: .core)
                    Image.miniArrowEndSolid
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.leading, 16)
            .padding(.trailing, horizontalPadding - 7) // -7 to offset the arrow's burnt in padding
            .hidden(viewModel.isOnLastPage(currentPageIndex: currentPageIndex))
        }
        .frame(height: 56)
        .foregroundColor(.textDarkest)
        .font(.regular16)
    }
}

#if DEBUG

struct K5ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next redundant_discardable_let
        let _ = K5Preview.setupK5Mode()

        K5ScheduleView(viewModel: K5Preview.Data.Schedule.rootModel)
            .previewDevice(PreviewDevice(stringLiteral: "iPhone 12"))
        K5ScheduleView(viewModel: K5Preview.Data.Schedule.rootModel)
            .previewDevice(PreviewDevice(stringLiteral: "iPad (9th generation)"))
    }
}

#endif
