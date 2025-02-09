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

struct ModulePublishProgressView: View {
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: ModulePublishProgressViewModel

    init(viewModel: ModulePublishProgressViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        content
            .navigationBarTitleView(title: title)
            .navigationBarItems(leading: dismissButton, trailing: trailingBarButton)
            .navigationBarStyle(.modal)
    }

    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            progressViewArea
                .padding(.vertical, 24)
            Divider()
            ScrollView {
                textArea
                    .padding(.vertical, 24)
            }
            Spacer()
        }
    }

    // MARK: - Navigation Bar

    private var title: String {
        switch viewModel.title {
        case .allModulesAndItems:
            String(localized: "All Modules and Items", bundle: .core)
        case .allModules:
            String(localized: "All Modules")
        case .selectedModuleAndItems:
            String(localized: "Selected Module and Items", bundle: .core)
        case .selectedModule:
            String(localized: "Selected Module", bundle: .core)
        }
    }

    @ViewBuilder
    private var dismissButton: some View {
        Button {
            viewModel.didTapDismiss.send(viewController)
        } label: {
            Image.xLine.navigationBarButtonStyle()
                .accessibilityLabel(Text("Dismiss", bundle: .core))
        }
        .accessibilityIdentifier("ModulePublish.dismissButton")
    }

    @ViewBuilder
    private var cancelButton: some View {
        let snackBarTitle = String(localized: "Update cancelled", bundle: .core)
        Button {
            viewModel.didTapCancel.send((viewController, snackBarTitle))
        } label: {
            Text("Cancel", bundle: .core).navigationBarButtonStyle()
        }
        .accessibilityIdentifier("ModulePublish.cancelButton")
    }

    @ViewBuilder
    private var doneButton: some View {
        Button {
            viewModel.didTapDone.send(viewController)
        } label: {
            Text("Done", bundle: .core).navigationBarButtonStyle()
        }
        .accessibilityIdentifier("ModulePublish.doneButton")
    }

    @ViewBuilder
    private var trailingBarButton: some View {
        switch viewModel.trailingBarButton {
        case .cancel: cancelButton
        case .done: doneButton
        }
    }

    // MARK: - Progress View area

    @ViewBuilder
    private var progressViewArea: some View {
        VStack(spacing: 8) {
            Text(progressTitle())
                .font(.regular14).foregroundStyle(Color.textDarkest)
                .accessibilityIdentifier("ModulePublish.progressTitle")
            ProgressView(value: viewModel.progress)
                .progressViewStyle(.determinateBar(color: viewModel.progressViewColor))
                .padding(.bottom, 8)
                .animation(.default, value: viewModel.progress)
                .accessibilityIdentifier("ModulePublish.progressIndicator")
        }
        .padding(.horizontal, 16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(progressTitle(forAccessibility: true)))
    }

    private func progressTitle(forAccessibility: Bool = false) -> String {
        let percentage = Int(viewModel.progress * 100)

        switch viewModel.state {
        case .inProgress:
            if viewModel.isPublish {
                return String(localized: "Publishing \(percentage)%", bundle: .core)
            } else {
                return String(localized: "Unpublishing \(percentage)%", bundle: .core)
            }
        case .completed:
            if viewModel.isPublish {
                return String(localized: "Published 100%", bundle: .core)
            } else {
                return String(localized: "Unpublished 100%", bundle: .core)
            }
        case .error:
            if forAccessibility {
                return String(localized: "Update failed at \(percentage)%", bundle: .core)
            } else {
                return String(localized: "Update failed", bundle: .core)
            }
        }
    }

    // MARK: - Text area

    @ViewBuilder
    private var textArea: some View {
        VStack(spacing: 0) {
            Text("This process could take a few minutes. You may close the modal or navigate away from the page during this process.", bundle: .core)
                .font(.regular16).foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)
            Text("Note", bundle: .core)
                .font(.regular14).foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            Text("Modules and items that have already been processed will not be reverted to their previous state when the process is discontinued.", bundle: .core)
                .font(.regular16).foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Helpers

private extension View {
    func navigationBarButtonStyle() -> some View {
        self
            .font(.semibold16)
            .foregroundStyle(Color.textDarkest)
    }
}

#if DEBUG

#Preview {
    let interactor = ModulePublishInteractorPreview(state: .loading)
    return ModulePublishProgressView(
        viewModel: .init(
            action: .publish(.onlyModules),
            allModules: true,
            moduleIds: [],
            interactor: interactor,
            router: AppEnvironment.shared.router
        )
    )
}

#endif
