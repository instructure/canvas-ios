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
                        label: Text("Title", bundle: .core),
                        placeholder: String(localized: "Add title (required)", bundle: .core),
                        text: $viewModel.title
                    )
                    .focused($focusedInput, equals: .title)
                    .identifier("Calendar.Todo.title")

                    InstUI.DatePickerCell(
                        label: Text("Date", bundle: .core),
                        identifierGroup: "Calendar.Todo.datePicker",
                        date: $viewModel.date
                    )

                    InstUI.LabelValueCell(
                        label: Text("Calendar", bundle: .core),
                        value: viewModel.calendarName,
                        action: {
                            viewModel.showCalendarSelector.send(viewController)
                        }
                    )
                    .identifier("Calendar.Todo.calendar")

                    InstUI.TextEditorCell(
                        label: Text("Details", bundle: .core),
                        text: $viewModel.details
                    )
                    .focused($focusedInput, equals: .details)
                    .identifier("Calendar.Todo.details")
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
            .frame(maxWidth: geometry.size.width, minHeight: geometry.size.height)
        }
        .navigationBarTitleView(viewModel.pageTitle)
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
        .navigationBarStyle(.modal)
        .errorAlert(isPresented: $viewModel.shouldShowSaveError, presenting: viewModel.saveErrorAlert)
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeEditToDoScreenPreview()
}

#endif
