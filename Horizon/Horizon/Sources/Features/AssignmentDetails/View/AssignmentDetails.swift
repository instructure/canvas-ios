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

struct AssignmentDetails: View {
    // MARK: - Dependencies

    @State private var viewModel: AssignmentDetailsViewModel
    @Binding private var isShowHeader: Bool
    @Binding private var isShowModuleNavBar: Bool

    // MARK: - Private Properties

    @State private var dismissKeyboard: Bool = false

    init(
        viewModel: AssignmentDetailsViewModel,
        isShowHeader: Binding<Bool> = .constant(false),
        isShowModuleNavBar: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._isShowHeader = isShowHeader
        self._isShowModuleNavBar = isShowModuleNavBar
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: .huiSpaces.space24) {
                    topView
                    introView
                        .id(viewModel.courseID)
                    if let submission = viewModel.submission {
                        mainContentView(
                            submission: submission,
                            proxy: proxy
                        )

                        errorView
                        if !viewModel.didSubmitBefore, let date = viewModel.lastDraftSavedAt {
                            draftView(date: date)
                        }
                        submitButton
                    }
                }
                .animation(.smooth, value: viewModel.didSubmitBefore)
                .padding(.huiSpaces.space24)
            }
        }
        .overlay { loaderView }
        .keyboardAdaptive()
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
            }
    }

    @ViewBuilder
    private func mainContentView(submission: HSubmission, proxy: ScrollViewProxy) -> some View {
        if viewModel.didSubmitBefore {
            MyAssignmentSubmissionAssembly.makeView(
                selectedSubmission: viewModel.selectedSubmission,
                submission: submission,
                courseId: viewModel.courseID
            )
            .id(submission.id)
        } else {
            AssignmentSubmissionView(
                viewModel: viewModel,
                isShowModuleNavBar: $isShowModuleNavBar,
                proxy: proxy,
                dismissKeyboard: dismissKeyboard
            )
            .onDisappear { viewModel.saveTextEntry() }
        }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.inverseSecondary.opacity(0.01)
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
            WebView(html: details)
                .frameToFit()
                .padding(.horizontal, -16)
        }
    }

    private var submitButton: some View {
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

    private func draftView(date: String) -> some View {
        HStack {
            Spacer()
            Text("\(AssignmentLocalizedKeys.savedAt.title) \(date)")
                .foregroundStyle(Color.huiColors.text.timestamp)
                .huiTypography(.p1)

            Button {
                viewModel.deleteDraft()
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
}

#if DEBUG
#Preview {
    AssignmentDetailsAssembly.makePreview()
}
#endif
