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

    @State private var isShowHeader = true
    @State private var isShowModuleNavBar = true
    @State private var submissionAlertModel = SubmissionAlertViewModel()
    @State private var draftToastViewModel = ToastViewModel()
    @State private var isHeaderAnimationEnabled = true
    @Environment(\.viewController) private var viewController
    private let keyboardObserver = KeyboardObserver()

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
            ContentView(viewModel: viewModel)
                .offset(x: viewModel.offsetX)
                .huiCornerRadius(level: .level5, corners: [.topRight, .topLeft])
                .onPreferenceChange(HeaderVisibilityKey.self) { isShow in
                    isHeaderAnimationEnabled = true
                    if isShowModuleNavBar {
                        isShowHeader = isShow
                    } else {
                        isShowHeader = false
                    }
                }
                .onPreferenceChange(AssignmentPreferenceKey.self) { model in
                    if let model {
                        switch model {
                        case .confirmation(viewModel: let viewModel):
                            submissionAlertModel = viewModel
                        case .toastViewModel(viewModel: let viewModel):
                            draftToastViewModel = viewModel
                        }
                    }
                }
        }
        .overlay { loaderView }
        .safeAreaInset(edge: .top, spacing: .zero) { introBlock }
        .safeAreaInset(edge: .bottom, spacing: .zero) { moduleNavBarView }
        .animation(isHeaderAnimationEnabled ? .linear : nil, value: isShowHeader)
        .alert(String(localized: "Error", bundle: .core), isPresented: $viewModel.isShowErrorAlert) {
            Button(String(localized: "Ok", bundle: .core), role: .cancel) {
                viewModel.pop(from: viewController)
            }
        } message: {
            Text(viewModel.errorMessage ?? String(localized: "An error occurred", bundle: .horizon))
        }
        .onWillDisappear { onShowNavigationBarAndTabBar(true) }
        .onWillAppear { onShowNavigationBarAndTabBar(false) }
        .huiToast(
            viewModel: .init(
                text: draftToastViewModel.title,
                style: .success
            ),
            isPresented: $draftToastViewModel.isPresented
        )
        .huiModal(headerTitle: submissionAlertModel.title,
                  headerIcon: submissionAlertModel.type == .success ? Image.huiIcons.checkCircleFull : nil,
                  headerIconColor: Color.huiColors.icon.success,
                  isShowCancelButton: submissionAlertModel.type == .confirmation,
                  confirmButton: submissionAlertModel.button,
                  isPresented: $submissionAlertModel.isPresented) { assignmentConfirmationView }
            .onChange(of: keyboardObserver.isKeyboardVisible) { _, newValue in
                isHeaderAnimationEnabled = false
                self.isShowHeader = !newValue
                self.isShowModuleNavBar = !newValue
            }
    }

    private var assignmentConfirmationView: some View {
        VStack(spacing: .huiSpaces.space24) {
            if submissionAlertModel.type == .success, let submission = submissionAlertModel.submission {
                Text(submissionAlertModel.body)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                AssignmentAttemptsRow(
                    submission: submission,
                    isSelected: false
                )
            } else {
                Text(submissionAlertModel.body)
                    .huiTypography(.p1)
                    .foregroundStyle(Color.huiColors.text.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
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
            IntroBlock(
                moduleName: viewModel.moduleItem?.moduleName ?? "",
                moduleItemName: viewModel.moduleItem?.title ?? "",
                duration: viewModel.estimatedTime,
                countOfPoints: viewModel.moduleItem?.points?.trimmedString,
                dueDate: viewModel.moduleItem?.dueAt?.formatted(format: "dd/MM"),
                isOverdue: viewModel.moduleItem?.isOverDue ?? false,
                attemptCount: viewModel.assignmentAttemptCount,
                isMenuButtonVisible: viewModel.isNextButtonEnabled || viewModel.isPreviousButtonEnabled,
                onBack: {
                    viewModel.pop(from: viewController)
                },
                onMenu: { viewModel.navigateToCourseProgress(from: viewController) }
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }

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
    private var moduleNavBarView: some View {
        if isShowModuleNavBar {
            let nextButton = ModuleNavBarView.ButtonAttribute(isVisible: viewModel.isNextButtonEnabled) {
                goNext()
            }
            let previousButton = ModuleNavBarView.ButtonAttribute(isVisible: viewModel.isPreviousButtonEnabled) {
                goPrevious()
            }

            ModuleItemSequenceAssembly.makeModuleNavBarView(
                nextButton: nextButton,
                previousButton: previousButton,
                visibleButtons: viewModel.visibleButtons
            )
            .id(viewModel.hasUnreadComments)
            .padding(.vertical, .huiSpaces.space8)
            .padding(.horizontal, .huiSpaces.space16)
            .background(Color.huiColors.surface.pagePrimary)
        }
    }
}
#if DEBUG
#Preview {
    ModuleItemSequenceAssembly.makeItemSequencePreview()
}
#endif

private struct ContentView: View {
    let viewModel: ModuleItemSequenceViewModel
    @Environment(\.viewController) private var viewController
    var body: some View {
        VStack {
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
                case let .page(context, pageURL, isMarkedAsDoneButtonVisible, isCompleted, moduleID, itemID):
                    PageDetailsAssembly.makeView(
                        context: context,
                        pageURL: pageURL,
                        isCompletedItem: isCompleted,
                        isMarkedAsDoneButtonVisible: isMarkedAsDoneButtonVisible,
                        moduleID: moduleID,
                        itemID: itemID
                    )
                    .id(pageURL)
                case .moduleItem(controller: let controller, let id):
                    ModuleItemSequenceAssembly.makeModuleItemView(viewController: controller)
                        .id(id)
                case .error:
                    ModuleItemSequenceAssembly.makeErrorView {
                        viewModel.retry()
                    }
                case .locked(title: let title, lockExplanation: let lockExplanation):
                    ModuleItemSequenceAssembly.makeLockView(title: title, lockExplanation: lockExplanation)
                case let .assignment(_, assignmentID, _, _, _, _):
                    if let assignmentViewModel = viewModel.assignmentDetailsViewModel {
                        AssignmentDetailsAssembly.makeView(viewModel: assignmentViewModel)
                            .id( assignmentID)
                    }

                case let .file(context, fileID):
                    FileDetailsAssembly.makeView(
                        courseID: viewModel.moduleItem?.courseID ?? "",
                        fileID: fileID,
                        context: context,
                        fileName: viewModel.moduleItem?.title ?? ""
                    )
                    .id(fileID)
                }
            }
        }
    }
}
