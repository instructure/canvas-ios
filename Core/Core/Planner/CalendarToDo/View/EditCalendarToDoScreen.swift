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

struct EditCalendarToDoScreen: View, ScreenViewTrackable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var viewController

    @ObservedObject private var viewModel: EditCalendarToDoViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    private enum FocusedInput {
        case title
        case details
    }
    @FocusState private var focusedInput: FocusedInput?

    init(viewModel: EditCalendarToDoViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
            VStack(alignment: .leading, spacing: 0) {
                VStack(spacing: 0) {
                    InstUI.TextFieldCell(
                        customAccessibilityLabel: Text("Title", bundle: .core),
                        placeholder: String(localized: "Add title", bundle: .core),
                        text: $viewModel.title
                    )
                    .focused($focusedInput, equals: .title)

                    InstUI.DatePickerCell(
                        label: Text("Date", bundle: .core),
                        date: $viewModel.date,
                        isClearable: false
                    )

                    InstUI.LabelValueCell(
                        label: Text("Calendar", bundle: .core),
                        value: viewModel.calendarName
                    ) {
                        let vc = CoreHostingController(
                            SelectCalendarScreen(viewModel: viewModel.selectCalendarViewModel)
                        )
                        env.router.show(vc, from: viewController, options: .push)
                    }

                    InstUI.TextEditorCell(
                        label: Text("Details", bundle: .core),
                        text: $viewModel.details
                    )
                    .focused($focusedInput, equals: .details)
                }
                // defocus inputs when otherwise non-tappable area is tapped
                .background(
                    InstUI.TapArea()
                        .onTapGesture {
                            focusedInput = nil
                        }
                )
                // focus 'Details' input when tapped below last cell
                InstUI.TapArea()
                    .layoutPriority(-1)
                    .onTapGesture {
                        focusedInput = .details
                    }
            }
            .frame(minHeight: geometry.size.height)
        }
        .navigationTitle(viewModel.pageTitle)
        .navBarItems(
            leading: .cancel {
                viewModel.didTapCancel.send()
            },
            trailing: .add(isEnabled: viewModel.isAddButtonEnabled) {
                viewModel.didTapAdd.send()
            }
        )
        .alert(
            Text("Unsuccessful Creation!", bundle: .core),
            isPresented: $viewModel.shouldShowAlert,
            actions: {
                Button(String(localized: "OK", bundle: .core)) {
                    viewModel.shouldShowAlert = false
                }
            },
            message: {
                Text("Your To Do was not added, you can try it again.", bundle: .core)
            }
        )
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeCreateToDoScreenPreview()
}

#endif
