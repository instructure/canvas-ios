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
import HorizonUI
import Core

struct AssignmentDetails: View {

    @FocusState private var focusedInput: Bool
    @State var html = ""
    // MARK: - Dependencies
    let uploadParameters: RichContentEditorUploadParameters = .init(context: .course("1"))
    @Bindable private var viewModel: AssignmentDetailsViewModel
    @Binding private var isShowHeader: Bool

    init(
        viewModel: AssignmentDetailsViewModel,
        isShowHeader: Binding<Bool> = .constant(false)
    ) {
        self.viewModel = viewModel
        self._isShowHeader = isShowHeader
    }

    var body: some View {
        ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        topView
                            .id("topView")
                            .padding(.top)
                        if viewModel.isLoaderVisible == false {
                            header
                        }
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
                            // try Comment this code
                            WebView(html: details)
                                .frameToFit()
                                .padding(.horizontal, -16)
                        }
                        if let lastSubmitted = viewModel.assignment?.submittedAt?.dateTimeString {
                            Size14RegularTextDarkestTitle(title: "Last Submitted: \(lastSubmitted)")
                        }

                        InstUI.RichContentEditorCell(
                            placeholder: String(localized: "Add your text entry", bundle: .horizon),
                            html: $html,
                            uploadParameters: uploadParameters,
                            onFocus: {
                                withAnimation {
                                    proxy.scrollTo("RichContentEditorCell", anchor: .bottom)
                                }
                            }
                        )
                        .id("RichContentEditorCell")
                        .onChange(of: html, { _, _ in
                            withAnimation {
                                proxy.scrollTo("RichContentEditorCell", anchor: .bottom)
                            }
                        })
                        .focused($focusedInput)
//                        .onChange(of: focusedInput) { oldValue, newValue in
//                            withAnimation {
//                                proxy.scrollTo("RichContentEditorCell", anchor: .bottom)
//                            }
//                         
//                        }
    //                    if !(viewModel.assignment?.assignmentTypes.isEmpty ?? false) {
    //                        AssignmentSubmissionView(viewModel: viewModel)
    //                            .disabled(viewModel.didSubmitAssignment)
    //                            .opacity(viewModel.didSubmitAssignment ? 0.5 : 1)
    //                            .hidden(!(viewModel.assignment?.showSubmitButton ?? false))
    //                    }
                    }
                    .paddingStyle(.horizontal, .standard)
//                    .padding(.bottom, 100)
                }
            }
        .overlay { loaderView }
        .background(Color.backgroundLightest)
        .keyboardAdaptive()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Error", isPresented: $viewModel.isAlertVisible) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            HorizonUI.Spinner(size: .small, showBackground: true)
        }
    }

    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
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

import Combine

struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
                    .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification))
                    .compactMap { notification in
                        notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                    }
                    .map { rect in
                        rect.height
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardHeight))

                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in
                        CGFloat(0)
                    }
                    .subscribe(Subscribers.Assign(object: self, keyPath: \.keyboardHeight))
            }
    }
}

extension View {
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
}
