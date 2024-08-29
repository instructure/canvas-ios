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
/*
import SwiftUI

struct EditEventFrequencyScreen: View, ScreenViewTrackable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.viewController) private var viewController

    @ObservedObject private var viewModel: EditCalendarEventViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    init(viewModel: EditCalendarEventViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {

            }
            .frame(minHeight: geometry.size.height)
        }
        .navigationTitle(viewModel.pageTitle)
        .navBarItems(
            leading: .cancel {
                viewModel.didTapCancel.send()
            },
            trailing: .init(
                isEnabled: viewModel.isSaveButtonEnabled,
                isAvailableOffline: false,
                title: viewModel.saveButtonTitle,
                action: {
                    viewModel.didTapSave.send()
                }
            )
        )
    }
}

#if DEBUG

#Preview {
   // EditEventFrequencyScreen()
}

#endif
*/
