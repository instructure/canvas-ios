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
        .navigationTitle(viewModel.pageTitle, subtitle: viewModel.pageSubtitle)
        .navigationBarStyle(.color(viewModel.contextColor))
    }

    private var eventContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            InstUI.Header(title: viewModel.title, subtitle: viewModel.date)
            InstUI.TextSectionView(viewModel.locationInfo)
            InstUI.TextSectionView(viewModel.details)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeEventDetailsScreenPreview()
}

#endif
