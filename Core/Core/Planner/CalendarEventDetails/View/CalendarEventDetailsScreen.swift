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

public struct CalendarEventDetailsScreen: View, ScreenViewTrackable {
    public var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @ObservedObject private var viewModel: CalendarEventDetailsViewModel

    public init(viewModel: CalendarEventDetailsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            refreshAction: viewModel.reload
        ) { _ in
            eventContent
        }
        .navigationTitle(viewModel.pageTitle, subtitle: viewModel.pageSubTitle)
        .navigationBarStyle(.color(viewModel.contextColor))
    }

    private var eventContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if viewModel.title != nil || viewModel.date != nil {
                VStack(alignment: .leading, spacing: 4) {
                    if let title = viewModel.title {
                        Text(title)
                            .textStyle(.heading)
                    }
                    if let date = viewModel.date {
                        Text(date)
                            .textStyle(.infoDescription)
                    }
                }
                .paragraphStyle(.heading)
            }

            InstUI.TextSectionView(viewModel.locationInfo)
            InstUI.TextSectionView(viewModel.details)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeEventDetailsPreview()
}

#endif
