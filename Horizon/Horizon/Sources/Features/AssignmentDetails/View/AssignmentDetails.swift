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

import Core
import SwiftUI

struct AssignmentDetails: View {
    // MARK: - Properties

    @Environment(\.viewController) private var viewController
    @Bindable private var viewModel: AssignmentDetailsViewModel

    init(viewModel: AssignmentDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: .init(refreshable: false)
        ) { geometry in
            ScrollViewReader { reader in
                VStack(spacing: 10) {
                    VStack(spacing: 8) {
                        Size14RegularTextDarkestTitle(title: viewModel.assignment?.dueAt ?? "")
                        if let pointsPossible = viewModel.assignment?.pointsPossible {
                            Size14RegularTextDarkestTitle(title: "\(pointsPossible) Points")
                        }
                        if (viewModel.assignment?.allowedAttempts ?? 0) > 0 {
                            Size14RegularTextDarkestTitle(title: "\(viewModel.assignment?.allowedAttempts ?? 0) attempt(s)")
                        } else {
                            Size14RegularTextDarkestTitle(title: "Unlimited Attempts Allowed")
                        }
                    }
                    .padding(.top, 8)

                    if let details = viewModel.assignment?.details {
                        WebView(html: details)
                            .frameToFit()
                            .padding(.horizontal, -16)
                    }
                    if let lastSubmitted = viewModel.assignment?.submittedAt?.dateTimeString {
                        Size14RegularTextDarkestTitle(title: "Last Submitted: \(lastSubmitted)")
                    }

                    if !(viewModel.assignment?.assignmentTypes.isEmpty ?? false) {
                        AssignmentSubmissionView(
                            viewModel: viewModel,
                            geometry: geometry) {
                                reader.scrollTo(viewModel.keyboardObserveID)
                            }
                            .disabled(viewModel.didSubmitAssignment)
                            .opacity(viewModel.didSubmitAssignment ? 0.5 : 1)
                            .hidden(!(viewModel.assignment?.showSubmitButton ?? false))
                    }
                }
            }
            .paddingStyle(.horizontal, .standard)
            .padding(.bottom, 100)
        }
        .background(Color.backgroundLight)
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top) { if viewModel.state == .data { header } }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.isKeyboardVisible {
                ModuleBottomNavBar { selectedButton in
                    viewModel.aiEvents.send((selectedButton, viewController))
                }
                .padding(.bottom)
            }
        }
        .onAppear { viewModel.showTabBar() }
        .avoidKeyboardArea()
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Error", isPresented: $viewModel.isAlertVisible) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    private var header: some View {
        LearningObjectHeaderView(
            type: "Assignment",
            duration: viewModel.assignment?.duration ?? "",
            courseName: viewModel.assignment?.courseName ?? "",
            courseProgress: viewModel.assignment?.courseProgress ?? 0.0,
            courseDueDate: viewModel.assignment?.courseDueDate ?? "",
            courseState: viewModel.assignment?.courseState ?? ""
        )
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .background(Color.backgroundLight)
    }
}

#if DEBUG
#Preview {
    AssignmentDetailsAssembly.makePreview()
}
#endif
