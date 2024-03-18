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
            .navigationTitleStyled(titleText.navigationBarTitleStyle())
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

    private var titleText: Text {
        switch viewModel.title {
        case .allModulesAndItems:
            Text("All Modules and Items")
        case .allModules:
            Text("All Modules")
        case .selectedModuleAndItems:
            Text("Selected Module and Items")
        case .selectedModule:
            Text("Selected Module")
        }
    }

    @ViewBuilder
    private var dismissButton: some View {
        Button {
            viewModel.didTapDismiss.send(viewController)
        } label: {
            Image.xLine.navigationBarButtonStyle()
        }
    }

    @ViewBuilder
    private var cancelButton: some View {
        Button {
            viewModel.didTapCancel.send(viewController)
        } label: {
            Text("Cancel").navigationBarButtonStyle()
        }
    }

    @ViewBuilder
    private var doneButton: some View {
        Button {
            viewModel.didTapDone.send(viewController)
        } label: {
            Text("Done").navigationBarButtonStyle()
        }
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
            progressText
                .font(.regular14).foregroundStyle(Color.textDarkest)
            ProgressView(value: viewModel.progress)
                .progressViewStyle(.determinateBar(color: viewModel.progressViewColor))
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var progressText: some View {
        switch viewModel.state {
        case .inProgress:
            let percentage = Int(viewModel.progress * 100)
            if viewModel.isPublish {
                Text("Publishing \(percentage)%")
            } else {
                Text("Unpublishing \(percentage)%")
            }
        case .completed:
            if viewModel.isPublish {
                Text("Published 100%")
            } else {
                Text("Unpublished 100%")
            }
        case .error:
            Text("Update failed")
        }
    }

    // MARK: - Text area

    @ViewBuilder
    private var textArea: some View {
        VStack(spacing: 0) {
            Text("This process could take a few minutes. You may close the modal or navigate away from the page during this process.")
                .font(.regular16).foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)
            Text("Note")
                .font(.regular14).foregroundStyle(Color.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)
            Text("Modules and items that have already been processed will not be reverted to their previous state when the process is discontinued.")
                .font(.regular16).foregroundStyle(Color.textDarkest)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Helpers

private extension View {
    func navigationBarTitleStyle() -> some View {
        self
            .font(.semibold16)
            .foregroundStyle(Color.textDarkest)
    }

    func navigationBarButtonStyle() -> some View {
        self
            .font(.semibold16)
            .foregroundStyle(Color.textDarkest)
    }
}

#Preview {
    ModulePublishProgressView(viewModel: .init(action: .publish(.onlyModules), allModules: true, router: AppEnvironment.shared.router))
}
