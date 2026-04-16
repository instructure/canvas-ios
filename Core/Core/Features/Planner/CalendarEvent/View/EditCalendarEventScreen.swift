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
            BaseScreen(state: viewModel.state, config: .notRefreshable) { geometry in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 0) {
                        AUI.TextFieldCell(
                            label: Text("Title", bundle: .core),
                            placeholder: String(localized: "Add title (required)", bundle: .core),
                            text: $viewModel.title
                        )
                        .focused($focusedInput, equals: .title)

                        AUI.DatePickerCell(
                            label: Text("Date", bundle: .core),
                            date: $viewModel.date,
                            mode: .dateOnly
                        )

                        AUI.ToggleCell(label: Text("All Day", bundle: .core), value: $viewModel.isAllDay)

                        if !viewModel.isAllDay {
                            AUI.DatePickerCell(
                                label: Text("From", bundle: .core),
                                customAccessibilityLabel: Text("Start time", bundle: .core),
                                date: $viewModel.startTime,
                                mode: .timeOnly
                            )

                            AUI.DatePickerCell(
                                label: Text("To", bundle: .core),
                                customAccessibilityLabel: Text("End time", bundle: .core),
                                date: $viewModel.endTime,
                                mode: .timeOnly,
                                errorMessage: viewModel.endTimeErrorMessage
                            )
                        }

                        AUI.LabelValueCell(
                            label: Text("Frequency", bundle: .core),
                            value: viewModel.frequencySelectionText,
                            action: {
                                viewModel.showFrequencySelector.send(viewController)
                            }
                        )

                        AUI.LabelValueCell(
                            label: Text("Calendar", bundle: .core),
                            value: viewModel.calendarName,
                            action: {
                                viewModel.showCalendarSelector.send(viewController)
                            }
                        )

                        AUI.TextEditorCell(
                            label: Text("Location", bundle: .core),
                            text: $viewModel.location
                        )
                        .focused($focusedInput, equals: .location)
                        AUI.Divider()

                        AUI.TextEditorCell(
                            label: Text("Address", bundle: .core),
                            text: $viewModel.address
                        )
                        .focused($focusedInput, equals: .address)
                        AUI.Divider()

                        AUI.RichContentEditorCell(
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
                        AUI.TapArea()
                            .onTapGesture {
                                focusedInput = nil
                            }
                    )
                    // focus 'Details' input when tapped below last cell
                    AUI.TapArea()
                        .layoutPriority(-1)
                        .onTapGesture {
                            focusedInput = .details
                        }
                }
                .frame(maxWidth: geometry.size.width, minHeight: geometry.size.height)
            }
        }
        .navBarItems(
            leading: AUI.NavigationBarButton.cancel {
                viewModel.didTapCancel.send()
            },
            trailing: AUI.NavigationBarButton(
                isEnabled: viewModel.isSaveButtonEnabled,
                isAvailableOffline: false,
                title: viewModel.saveButtonTitle,
                action: {
                    viewModel.didTapSave.send()
                }
            )
            .confirmation(
                isPresented: $viewModel.shouldShowEditConfirmation,
                presenting: viewModel.editConfirmation
            )
        )
        .navigationTitle(viewModel.pageTitle, style: .modal)
        .errorAlert(isPresented: $viewModel.shouldShowSaveError, presenting: viewModel.saveErrorAlert)
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeEditEventScreenPreview()
}

#endif
