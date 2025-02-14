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
    // MARK: - Private Properties

    @State private var isShowMakeAsDoneSheet = false
    @State private var isShowHeader = true
    @State private var attemptCount: String?
    @Environment(\.viewController) private var viewController

    // MARK: - Dependencies

    @State var viewModel: ModuleItemSequenceViewModel
    private let onShowNavigationBarAndTabBar: (Bool) -> Void

    // MARK: - Init

    init(viewModel: ModuleItemSequenceViewModel,
         onShowNavigationBarAndTabBar: @escaping (Bool) -> Void) {
        self.viewModel = viewModel
        self.onShowNavigationBarAndTabBar = onShowNavigationBarAndTabBar
    }

    public var body: some View {
        ZStack(alignment: .center) {

            Color.huiColors.surface.institution
                .ignoresSafeArea(edges: .top)
            Rectangle()
                .fill(Color.huiColors.surface.pageSecondary)
                .huiCornerRadius(level: .level5, corners: [.topRight, .topLeft])
            mainContent
                .offset(x: viewModel.offsetX)
                .huiCornerRadius(level: .level5, corners: [.topRight, .topLeft])
        }
        .overlay { loaderView }
        .safeAreaInset(edge: .top, spacing: .zero) { introBlock }
        .safeAreaInset(edge: .bottom, spacing: .zero) { moduleNavBarView }
        .animation(.linear, value: isShowHeader)
        .confirmationDialog("", isPresented: $isShowMakeAsDoneSheet, titleVisibility: .hidden) {
            makeAsDoneSheetButtons
        }
        .alert(String(localized: "Error", bundle: .core), isPresented: $viewModel.isShowErrorAlert) {
            Button(String(localized: "Ok", bundle: .core), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onWillDisappear { onShowNavigationBarAndTabBar(true) }
        .onWillAppear { onShowNavigationBarAndTabBar(false) }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            HorizonUI.Spinner(size: .small, showBackground: true)
        }
    }
    @ViewBuilder
    private var introBlock: some View {
        if isShowHeader {
            HorizonUI.IntroBlock(
                moduleName: viewModel.moduleItem?.moduleName ?? "",
                moduleItemName: viewModel.moduleItem?.title ?? "",
                duration: "22 Mins", // TODO Set real value
                countOfPoints: viewModel.moduleItem?.points,
                dueDateTime: viewModel.moduleItem?.dueAt?.formatted(format: "dd/MM, h:mm a"),
                isOverdue: viewModel.moduleItem?.isOverDue ?? false,
                attemptCount: attemptCount,
                onBack: {
                    viewModel.pop(from: viewController)
                },
                onMenu: { viewModel.navigateToCourseProgress(from: viewController) }
            )
            .transition(.move(edge: .top).combined(with: .opacity))
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

    // TODO: - Set the mark done in navBar button later
//    @ViewBuilder
//    private var makeAsDoneButton: some View {
//        if viewModel.moduleItem?.completionRequirementType == .must_mark_done {
//            Button(action: {
//                isShowMakeAsDoneSheet = true
//            }) {
//                Image.huiIcons.moreHoriz
//                    .foregroundStyle(Color.huiColors.text.body)
//            }
//        }
//    }

    private func goNext() {
        withAnimation {
            viewModel.offsetX = -UIScreen.main.bounds.width * 2
        } completion: {
            viewModel.goNext()
            isShowHeader = true
        }
    }

    private func goPrevious() {
        withAnimation {
            viewModel.offsetX = UIScreen.main.bounds.width * 2
        } completion: {
            viewModel.goPrevious()
            isShowHeader = true
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if let state = viewModel.viewState {
            switch state {
            case .externalURL(url: let url, name: let name):
                ModuleItemSequenceAssembly.makeExternalURLView(
                    name: name,
                    url: url,
                    viewController: viewController
                )
                .id(url.absoluteString)
            case .externalTool(tools: let tools, name: let name):
                ModuleItemSequenceAssembly.makeLTIView(
                    tools: tools,
                    name: name
                )
                .id(tools.url?.absoluteString)
            case .moduleItem(controller: let controller, let id):
                ModuleItemSequenceAssembly.makeModuleItemView(
                    isScrollTopReached: $isShowHeader,
                    viewController: controller
                )
                .id(id)
            case .error:
                ModuleItemSequenceAssembly.makeErrorView {
                    viewModel.retry()
                }
            case .locked(title: let title, lockExplanation: let lockExplanation):
                ModuleItemSequenceAssembly.makeLockView(title: title, lockExplanation: lockExplanation)
            case .assignment(courseID: let courseID, assignmentID: let assignmentID):
                AssignmentDetailsAssembly.makeView(
                    courseID: courseID,
                    assignmentID: assignmentID,
                    isShowHeader: $isShowHeader
                ) { attemptCount in
                    self.attemptCount = attemptCount

                }

            case let .file(context, fileID):
                FileDetailsAssembly.makeView(
                    courseID: viewModel.moduleItem?.courseID ?? "",
                    fileID: fileID,
                    context: context,
                    fileName: viewModel.moduleItem?.title ?? "",
                    isShowHeader: $isShowHeader
                )
                .id(fileID)
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
        .padding(.vertical, .huiSpaces.primitives.xSmall)
        .padding(.horizontal, .huiSpaces.primitives.mediumSmall)
        .background(Color.huiColors.surface.pagePrimary)
        .frame(height: 56)
    }
}
#if DEBUG
#Preview {
    ModuleItemSequenceAssembly.makeItemSequencePreview()
}
#endif
