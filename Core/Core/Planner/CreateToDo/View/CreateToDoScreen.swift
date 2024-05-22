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

struct CreateToDoScreen: View, ScreenViewTrackable {
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: CreateToDoViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    init(viewModel: CreateToDoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: .data, config: viewModel.screenConfig) { _ in
            VStack(spacing: 0) {
                InstUI.TextFieldCell(
                    placeholder: String(localized: "Add title", bundle: .core),
                    text: $viewModel.title
                )
                InstUI.DatePickerCell(
                    label: Text("Date", bundle: .core),
                    date: $viewModel.date,
                    isClearable: false
                )
                InstUI.LabelValueCell(
                    label: Text("Calendar", bundle: .core),
                    value: viewModel.calendar
                ) {
                    Text(verbatim: "some new screen")
                }
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .navBarItems(
            leading: .cancel {
                viewModel.didTapCancel.send(viewController)
            },
            trailing: .add(isEnabled: viewModel.isAddButtonEnabled) {
                viewModel.didTapAdd.send(viewController)
            }
        )
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeCreateToDoScreenPreview()
}

#endif
