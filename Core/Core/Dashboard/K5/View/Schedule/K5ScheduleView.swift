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

public struct K5ScheduleView: View {
    @ObservedObject var viewModel: K5ScheduleViewModel
    @Environment(\.containerSize) private var containerSize

    public var body: some View {
        let collectionViewWrapper = WeakObject<UICollectionView>()
        HorizontalPager(pageCount: viewModel.weekModels.count, size: containerSize, initialPageIndex: viewModel.defaultWeekIndex, proxy: collectionViewWrapper) { pageIndex in
            K5ScheduleWeekView(viewModel: viewModel.weekModels[pageIndex])
        }
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
            .previewDevice(PreviewDevice(stringLiteral: "iPad (8th generation)"))
    }
}

#endif
