//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import HorizonUI
import Core

public struct ModuleItemSequenceView: View {
    @State var viewModel: ModuleItemSequenceViewModel
    @State private var isShowMakeAsDoneSheet = false

    public var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: .zero) {
                mainContent
                    .offset(x: viewModel.offsetX)
            }
            .frame(maxHeight: .infinity)
            .safeAreaInset(edge: .bottom, spacing: .zero) { moduleNavBarView }
            if viewModel.isLoaderVisible {
                HorizonUI.Spinner(size: .medium, showBackground: true)
            }
        }
        .confirmationDialog("", isPresented: $isShowMakeAsDoneSheet, titleVisibility: .hidden) {
            makeAsDoneSheetButtons
        }
        .alert(String(localized: "Error", bundle: .core), isPresented: $viewModel.isShowErrorAlert) {
            Button(String(localized: "Ok", bundle: .core), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { makeAsDoneButton }
            ToolbarItem(placement: .principal) {
                VStack(spacing: .huiSpaces.primitives.xxxSmall) {
                    Text(viewModel.moduleItem?.title ?? "")
                        .foregroundStyle(Color.huiColors.text.body)
                        .huiTypography(.labelLargeBold)
                    Text(viewModel.courseName)
                        .foregroundStyle(Color.huiColors.primitives.grey24)
                        .huiTypography(.labelSmall)
                }
            }
        }
    }

    @ViewBuilder
    private var makeAsDoneSheetButtons: some View {
        let title = viewModel.moduleItem?.completed == true
        ? String(localized: "Mark as Undone", bundle: .core)
        : String(localized: "Mark as Done", bundle: .core)
        Button(title) { viewModel.markAsDone()}
        Button(String(localized: "Cancel", bundle: .core), role: .cancel) {}
    }

    @ViewBuilder
    private var makeAsDoneButton: some View {
        if viewModel.moduleItem?.completionRequirementType == .must_mark_done {
            Button(action: {
                isShowMakeAsDoneSheet = true
            }) {
                Image.huiIcons.moreHoriz
                    .foregroundStyle(Color.huiColors.text.body)
            }
        }
    }

    private func goNext() {
        withAnimation {
            viewModel.offsetX = -UIScreen.main.bounds.width * 2
        } completion: {
            viewModel.goNext()
        }
    }

    private func goPrevious() {
        withAnimation {
            viewModel.offsetX = UIScreen.main.bounds.width * 2
        } completion: {
            viewModel.goPrevious()
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if let state = viewModel.viewState {
            switch state {
            case .externalURL(url: let url, environment: let environment, name: let name, courseID: let courseID):
                ModuleItemSequenceAssembly.makeExternalURLView(
                    environment: environment,
                    name: name,
                    url: url,
                    courseID: courseID
                )
                .id(url.absoluteString)
            case .externalTool(environment: let environment, tools: let tools, name: let name):
                ModuleItemSequenceAssembly.makeLTIView(
                    environment: environment,
                    tools: tools,
                    name: name
                )
                .id(tools.url?.absoluteString)
            case .moduleItem(controller: let controller, let id):
                ModuleItemSequenceAssembly.makeModuleItemView(viewController: controller)
                    .id(id)
            case .error:
                ModuleItemSequenceAssembly.makeErrorView {
                    viewModel.retry()
                }
            case .locked(title: let title, lockExplanation: let lockExplanation):
                ModuleItemSequenceAssembly.makeLockView(title: title, lockExplanation: lockExplanation)
            }
        }
    }

    private var moduleNavBarView: some View {
        ModuleItemSequenceAssembly.makeModuleNavBarView(
            isNextButtonEnabled: viewModel.isNextButtonEnabled,
            isPreviousButtonEnabled: viewModel.isPreviousButtonEnabled
        ) {
            goNext()
        } didTapPrevious: {
            goPrevious()
        }
        .frame(height: 56)
    }
}
#if DEBUG
#Preview {
    ModuleItemSequenceAssembly.makeItemSequencePreview()
}
#endif
