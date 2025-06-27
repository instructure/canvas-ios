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

import Core
import HorizonUI
import SwiftUI

struct AssignmentDetails: View {
    // MARK: - Dependencies

    @State private var viewModel: AssignmentDetailsViewModel

    // MARK: - Private Properties

    @State private var dismissKeyboard: Bool = false
    @State private var isShowHeader: Bool = true
    @Environment(\.viewController) private var viewController

    init(viewModel: AssignmentDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                if let submission = viewModel.submission, viewModel.shouldShowViewAttempts {
                    viewAttemptText(attempt: submission.attempt)
                }
                topView
                VStack(spacing: .huiSpaces.space24) {
                    startQuizButton
                    introView
                        .id(viewModel.dependency.courseID)
                    mainContentView(proxy: proxy)
                    errorView
                    if !viewModel.hasSubmittedBefore, let date = viewModel.lastDraftSavedAt {
                        draftView(date: date)
                    }
                    VStack {
                        submitButton
                        if viewModel.dependency.isMarkedAsDone {
                            markAsDoneButton
                        }
                    }
                    .padding(.bottom, .huiSpaces.space48)
                }
                .animation(.smooth, value: viewModel.hasSubmittedBefore)
                .padding(.huiSpaces.space24)
            }
        }
        .overlay { loaderView }
        .keyboardAdaptive(isEnabled: viewModel.selectedSubmission == .text)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .scrollDismissesKeyboard(isShowHeader ? .immediately : .never)
        .preference(key: AssignmentPreferenceKey.self, value: viewModel.assignmentPreference)
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
        .huiOverlay(
            title: AssignmentLocalizedKeys.tools.title,
            buttons: makeOverlayToolButtons(),
            isPresented: $viewModel.isOverlayToolsPresented
        )
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
            }
    }

    private func viewAttemptText(attempt: Int) -> some View {
        HStack(spacing: .huiSpaces.space2) {
            Text("VIEWING ATTEMPT", bundle: .horizon)
            Text(attempt.description)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .huiSpaces.space8)
        .foregroundStyle(Color.huiColors.surface.institution)
        .background(Color.huiColors.surface.pagePrimary)
        .huiTypography(.p2)
    }

    @ViewBuilder
    private func mainContentView(proxy: ScrollViewProxy) -> some View {
        if let submission = viewModel.submission, viewModel.hasSubmittedBefore {
            MyAssignmentSubmissionAssembly.makeView(
                selectedSubmission: submission.type ?? .text,
                submission: submission,
                courseId: viewModel.dependency.courseID
            )
        } else {
            AssignmentSubmissionView(
                viewModel: viewModel,
                proxy: proxy,
                dismissKeyboard: dismissKeyboard
            )
        }
    }

    @ViewBuilder
    private var startQuizButton: some View {
        if viewModel.assignment?.isQuizLTI == true {
            HorizonUI.PrimaryButton(
                String(localized: "Start Quiz", bundle: .horizon),
                type: .institution,
                isSmall: false
            ) {
                viewModel.showQuizLTI(controller: viewController)
            }
            .padding(.top, -(.huiSpaces.space24))
        }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.pageSecondary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }

    @ViewBuilder
    private var errorView: some View {
        if let errorMessage = viewModel.errorMessage {
            HStack {
                Spacer()
                Image.huiIcons.error
                    .frame(width: 19, height: 19)
                Text(errorMessage)
                    .huiTypography(.p1)
            }
            .foregroundStyle(Color.huiColors.text.error)
        }
    }

    @ViewBuilder
    private var introView: some View {
        if let details = viewModel.assignment?.details {
            VStack(spacing: .huiSpaces.space4) {
                Text("Instructions", bundle: .horizon)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .huiTypography(.h3)
                    .foregroundStyle( Color.huiColors.text.title)
                WebView(html: details, isScrollEnabled: false)
                    .frameToFit()
                    .padding(.horizontal, -16)
                    .id(details)
            }
        }
    }

    @ViewBuilder
    private var submitButton: some View {
        if !viewModel.isSubmitButtonHidden {
            HStack {
                Spacer()
                HorizonUI.PrimaryButton(viewModel.submitButtonTitle) {
                    dismissKeyboard.toggle()
                    viewModel.submit()
                }
                .disableWithOpacity(!viewModel.shouldEnableSubmitButton, disabledOpacity: 0.7)
                .hidden(!(viewModel.assignment?.showSubmitButton ?? false))
            }
        }
    }

    private var markAsDoneButton: some View {
        MarkAsDoneButton(
            isCompleted: viewModel.dependency.isCompletedItem,
            isLoading: viewModel.isMarkAsDoneLoaderVisible
        ) {
            viewModel.markAsDone()
        }
    }

    private func draftView(date: String) -> some View {
        HStack {
            Spacer()
            Text("\(AssignmentLocalizedKeys.savedAt.title) \(date)")
                .foregroundStyle(Color.huiColors.text.timestamp)
                .huiTypography(.p1)

            Button {
                viewModel.showDraftAlert()
            } label: {
                HStack(spacing: .zero) {
                    Image.huiIcons.delete
                        .frame(width: 24, height: 24)
                    Text(AssignmentLocalizedKeys.deleteDraft.title)
                        .huiTypography(.buttonTextLarge)
                }
                .foregroundStyle(Color.huiColors.text.error)
            }
        }
    }

    private func makeOverlayToolButtons() -> [HorizonUI.Overlay.ButtonAttribute] {
        let historyButton = HorizonUI.Overlay.ButtonAttribute(
            title: AssignmentLocalizedKeys.attemptHistory.title,
            icon: Image.huiIcons.history
        ) {
            viewModel.isOverlayToolsPresented.toggle()
            // Wait until the tools sheet is dismissed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                viewModel.viewAttempts(controller: viewController)
            }
        }

        let commentButton = HorizonUI.Overlay.ButtonAttribute(
            title: AssignmentLocalizedKeys.comments.title,
            icon: viewModel
                .submissionProperties?
                .hasUnreadComments == true ? Image.huiIcons.markUnreadChat : Image.huiIcons.chat
        ) {
            viewModel.isOverlayToolsPresented.toggle()
            // Wait until the tools sheet is dismissed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                viewModel.viewComments(controller: viewController)
            }
        }
        return [historyButton, commentButton]
    }
}

#if DEBUG
#Preview {
    AssignmentDetailsAssembly.makePreview()
}
#endif
