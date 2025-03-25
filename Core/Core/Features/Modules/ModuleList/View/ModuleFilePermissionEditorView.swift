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

import Combine
import SwiftUI

struct ModuleFilePermissionEditorView: View {
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: ModuleFilePermissionEditorViewModel

    init(viewModel: ModuleFilePermissionEditorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        SwiftUI.Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .error:
                InteractivePanda(
                    scene: FilesPanda(),
                    title: Text("Something went wrong", bundle: .core),
                    subtitle: Text("There was an unexpected error. Please try again.", bundle: .core)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            case .data:
                form
            }
        }
        .background(Color.backgroundLightest)
        .navigationBarTitleView(String(localized: "Edit Permissions", bundle: .core))
        .navigationBarItems(leading: cancelNavButton)
        .navigationBarStyle(.modal)
    }

    private var form: some View {
        EditorForm(isSpinning: viewModel.isUploading) {
            EditorSection(label: Text("Availability", bundle: .core)) {
                ForEach(FileAvailability.allCases) { availability in
                    let binding = Binding {
                        viewModel.availability == availability
                    } set: { _ in
                        viewModel.availabilityDidSelect.send(availability)
                    }
                    CheckmarkRow(isChecked: binding, label: Text(availability.label))
                        .animation(.none, value: viewModel.isScheduleDateSectionVisible)
                    separator.hidden(availability.isLastCase ? true : false)
                }

                if viewModel.isScheduleDateSectionVisible {
                    availabilityDatesSection
                }
            }

            EditorSection(label: Text("Visibility", bundle: .core)) {
                ForEach(FileVisibility.allCases) { visibility in
                    let binding = Binding {
                        viewModel.visibility == visibility
                    } set: { _ in
                        viewModel.visibilityDidSelect.send(visibility)
                    }
                    CheckmarkRow(isChecked: binding, label: Text(visibility.label))
                    separator.hidden(visibility.isLastCase ? true : false)
                }

            }
        }
        .animation(.default, value: viewModel.isScheduleDateSectionVisible)
        .navigationBarItems(trailing: doneNavButton)
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Something went wrong", bundle: .core),
                message: Text("There was an unexpected error. Please try again.", bundle: .core)
            )
        }
    }

    @ViewBuilder
    private var availabilityDatesSection: some View {
        let fromBinding = Binding(get: { viewModel.availableFrom },
                                  set: { viewModel.availableFromDidSelect.send($0) })
        let untilBinding = Binding(get: { viewModel.availableUntil },
                                   set: { viewModel.availableUntilDidSelect.send($0) })
        VStack(spacing: 0) {
            separator.padding(.leading, 16)
            DatePickerRow(date: fromBinding,
                          defaultDate: viewModel.defaultFromDate,
                          validUntil: viewModel.availableUntil?.addMinutes(-1) ?? .distantFuture,
                          label: Text("From", bundle: .core))
            .animation(.default, value: viewModel.availableFrom)
            separator.padding(.leading, 16)
            DatePickerRow(date: untilBinding,
                          defaultDate: viewModel.defaultUntilDate,
                          validFrom: viewModel.availableFrom?.addMinutes(1) ?? .distantPast,
                          label: Text("Until", bundle: .core))
            .animation(.default, value: viewModel.availableUntil)
        }
        .transition(.move(edge: .top))
        .zIndex(-1)
    }

    private var cancelNavButton: some View {
        Button {
            viewModel.cancelDidPress.send(viewController.value)
        } label: {
            Text("Cancel", bundle: .core)
        }
    }

    private var doneNavButton: some View {
        Button {
            viewModel.doneDidPress.send(viewController.value)
        } label: {
            Text("Done", bundle: .core)
        }
        .disabled(!viewModel.isDoneButtonActive)
    }

    private var separator: some View {
        Color.borderMedium
            .frame(height: 1 / UIScreen.main.scale)
    }
}

private extension FileAvailability {
    var label: String {
        switch self {
        case .published: return String(localized: "Publish", bundle: .core)
        case .unpublished: return String(localized: "Unpublish", bundle: .core)
        case .hidden: return String(localized: "Only Available With Link", bundle: .core)
        case .scheduledAvailability: return String(localized: "Schedule Availability", bundle: .core)
        }
    }
}

#if DEBUG

struct ModuleFilePermissionEditorView_Previews: PreviewProvider {
    static var previews: some View {
        let loadingInteractor = ModulePublishInteractorPreview(state: .loading)
        let errorInteractor = ModulePublishInteractorPreview(state: .error)
        let dataInteractor = ModulePublishInteractorPreview(state: .data)

        let dataViewModel = ModuleFilePermissionEditorViewModel(
            fileContext: .init(
                fileId: "",
                moduleId: "",
                moduleItemId: "",
                courseId: ""
            ),
            interactor: dataInteractor,
            router: AppEnvironment.shared.router
        )
        ModuleFilePermissionEditorView(viewModel: dataViewModel)
            .previewDisplayName("Data")
        let loadingViewModel = ModuleFilePermissionEditorViewModel(
            fileContext: .init(
                fileId: "",
                moduleId: "",
                moduleItemId: "",
                courseId: ""
            ),
            interactor: loadingInteractor,
            router: AppEnvironment.shared.router
        )
        ModuleFilePermissionEditorView(viewModel: loadingViewModel)
            .previewDisplayName("Loading")
        let errorViewModel = ModuleFilePermissionEditorViewModel(
            fileContext: .init(
                fileId: "",
                moduleId: "",
                moduleItemId: "",
                courseId: ""
            ),
            interactor: errorInteractor,
            router: AppEnvironment.shared.router
        )
        ModuleFilePermissionEditorView(viewModel: errorViewModel)
            .previewDisplayName("Error")
    }
}

#endif
