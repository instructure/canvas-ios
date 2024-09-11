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

struct EditCalendarEventScreen: View, ScreenViewTrackable {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.viewController) private var viewController

    @ObservedObject private var viewModel: EditCalendarEventViewModel

    var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    private enum FocusedInput {
        case title
        case location
        case address
        case details
    }
    @FocusState private var focusedInput: FocusedInput?

    init(viewModel: EditCalendarEventViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollViewReader { scrollProxy in
            InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        InstUI.TextFieldCell(
                            label: Text("Title", bundle: .core),
                            placeholder: String(localized: "Add title", bundle: .core),
                            text: $viewModel.title
                        )
                        .focused($focusedInput, equals: .title)

                        InstUI.DatePickerCell(
                            label: Text("Date", bundle: .core),
                            date: $viewModel.date,
                            mode: .dateOnly,
                            isClearable: false
                        )

                        InstUI.ToggleCell(label: Text("All Day", bundle: .core), value: $viewModel.isAllDay)

                        if !viewModel.isAllDay {
                            InstUI.DatePickerCell(
                                label: Text("From", bundle: .core),
                                date: $viewModel.startTime,
                                mode: .timeOnly,
                                isClearable: false
                            )

                            InstUI.DatePickerCell(
                                label: Text("To", bundle: .core),
                                date: $viewModel.endTime,
                                mode: .timeOnly,
                                errorMessage: viewModel.endTimeErrorMessage,
                                isClearable: false
                            )
                        }

                        InstUI.LabelValueCell(
                            label: Text("Frequency", bundle: .core),
                            value: viewModel.frequencySelectionText,
                            action: {
                                viewModel.showFrequencySelector.send(viewController)
                            }
                        )

                        InstUI.LabelValueCell(
                            label: Text("Calendar", bundle: .core),
                            value: viewModel.calendarName,
                            action: {
                                viewModel.showCalendarSelector.send(viewController)
                            }
                        )

                        InstUI.TextEditorCell(
                            label: Text("Location", bundle: .core),
                            text: $viewModel.location
                        )
                        .focused($focusedInput, equals: .location)
                        InstUI.Divider()

                        InstUI.TextEditorCell(
                            label: Text("Address", bundle: .core),
                            text: $viewModel.address
                        )
                        .focused($focusedInput, equals: .address)
                        InstUI.Divider()

                        InstUI.RichContentEditorCell(
                            label: Text("Details", bundle: .core),
                            html: $viewModel.details,
                            uploadParameters: viewModel.uploadParameters,
                            isUploading: $viewModel.isUploading,
                            onFocus: {
                                // wait a bit for keyboard to start appearing, so it's considered during scroll
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation {
                                        scrollProxy.scrollTo("details", anchor: .bottom)
                                    }
                                }
                            }
                        )
                        .id("details")
                        .focused($focusedInput, equals: .details)
                    }
                    .animation(.default, value: viewModel.isAllDay)

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
        .errorAlert(isPresented: $viewModel.shouldShowSaveError, presenting: viewModel.saveErrorAlert)
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeEditEventScreenPreview()
}

#endif
