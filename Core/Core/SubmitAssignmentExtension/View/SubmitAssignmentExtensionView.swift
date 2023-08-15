//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct SubmitAssignmentExtensionView: View {
    private enum AccessibilityFocusArea: Hashable, Equatable {
        case course, assignment
    }

    @Environment(\.viewController) private var viewController
    @Environment(\.appEnvironment) private var env
    @ObservedObject private var viewModel: SubmitAssignmentExtensionViewModel

    @AccessibilityFocusState private var accessibilityFocus: AccessibilityFocusArea?

    public init(viewModel: SubmitAssignmentExtensionViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            if viewModel.isUserLoggedIn {
                contentView
            } else {
                notLoggedInView
            }
        }
        .navigationViewStyle(.stack)
        .onReceive(viewModel.showUploadStateView, perform: showFileProgressView)
    }

    private var notLoggedInView: some View {
        Text("Please log in via the application")
            .foregroundColor(.textDarkest)
            .font(.regular16)
            .navigationBarGlobal()
            .navigationTitleStyled(title)
            .navigationBarTitleDisplayMode(.inline)
            .navBarItems(trailing: cancelButton)
    }

    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                selectCourseButton
                divider
                selectAssignmentButton
                commentBox
                divider
                filesSection
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationBarGlobal()
        .navigationTitleStyled(title)
        .navigationBarTitleDisplayMode(.inline)
        .navBarItems(leading: cancelButton, trailing: submitButton)
        .onDisappear {
            accessibilityFocus = nil
        }
    }

    private var title: Text {
        Text("Canvas Student", bundle: .core).font(.semibold17).foregroundColor(.textDarkest)
    }

    @ViewBuilder
    private var commentBox: some View {
        TextEditor(text: $viewModel.comment)
            .foregroundColor(.textDarkest)
            .style(.body)
            .frame(height: 100)
            .padding(.vertical, 13) // TextEditor has a default 7 point padding so 20 - 7
            .padding(.trailing, -20) // Offset parent's padding so our scrollbar will be in line with parent's scrollbar
            .padding(.leading, -5) // Offset TextEditor's default padding so we'll be in line with the course and assignment picker cells
            .overlay(placeholder, alignment: .topLeading)
            .accessibilityLabel(NSLocalizedString("Add optional comment", comment: ""))
            .toolbar { hideKeyboardButton }
    }

    @ViewBuilder
    private var placeholder: some View {
        if viewModel.comment.isEmpty {
            Text("Add comment (optional)", comment: "")
                .foregroundColor(.textDark)
                .font(.regular16)
                .padding(.top, 21)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private var hideKeyboardButton: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            HStack {
                Spacer()
                Button(action: {
                    viewController.view.endEditing(true)
                }) {
                    Text("Done", bundle: .core)
                        .font(.bold17)
                }
            }
        }
    }

    private var selectCourseButton: some View {
        NavigationLink(destination: CoursePickerView(viewModel: viewModel.coursePickerViewModel)) {
            HStack {
                viewModel.selectCourseButtonTitle
                    .foregroundColor(viewModel.coursePickerViewModel.selectedCourse == nil ? .textDark : .textDarkest)
                    .font(.regular16)
                    .multilineTextAlignment(.leading)
                Spacer()
                InstDisclosureIndicator().padding(.leading, 10)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityFocused($accessibilityFocus, equals: .course)
        .onReceive(viewModel.coursePickerViewModel.dismissViewDidTrigger) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                accessibilityFocus = .course
            }
        }
        .frame(height: 54)
    }

    private var divider: some View {
        Divider().padding(.horizontal, -20)
    }

    @ViewBuilder
    private var selectAssignmentButton: some View {
        if viewModel.assignmentPickerViewModel.courseID != nil {
            let viewToPush = AssignmentPickerView(viewModel: viewModel.assignmentPickerViewModel)
            NavigationLink(destination: viewToPush) {
                VStack(spacing: 0) {
                    HStack {
                        viewModel.selectAssignmentButtonTitle
                            .foregroundColor(viewModel.assignmentPickerViewModel.selectedAssignment == nil ? .textDark : .textDarkest)
                            .font(.regular16)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        InstDisclosureIndicator().padding(.leading, 10)
                    }
                        .frame(height: 54)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibilityFocused($accessibilityFocus, equals: .assignment)
            .onReceive(viewModel.assignmentPickerViewModel.dismissViewDidTrigger) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    accessibilityFocus = .assignment
                }
            }
            divider
        }
    }

    private var cancelButton: some View {
        Button(action: viewModel.cancelTapped) {
            Text("Cancel", bundle: .core)
                .foregroundColor(.crimson)
                .font(.regular17)
        }
    }

    @ViewBuilder
    private var submitButton: some View {
        if viewModel.isProcessingFiles {
            ProgressView()
                .progressViewStyle(.indeterminateCircle(size: 20))
        } else {
            Button(action: viewModel.submitTapped) {
                Text("Submit", bundle: .core)
                    .font(.semibold17)
            }
            .disabled(viewModel.isSubmitButtonDisabled)
        }
    }

    private var filesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String.localizedStringWithFormat(NSLocalizedString("d_items", comment: ""), viewModel.previews.count))
                .font(.regular12)
                .foregroundColor(.textDark)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer().frame(width: 20)
                    ForEach(viewModel.previews) {
                        AttachmentPreviewView(viewModel: $0)
                    }
                    Spacer().frame(width: 20)
                }
            }
                .padding(.top, 10)
                .padding(.horizontal, -20)
        }
        .padding(.top, 20)
    }

    private func showFileProgressView(_ viewModel: FileProgressListViewModel) {
        let listView = FileProgressListView(viewModel: viewModel)
        let listViewController = CoreHostingController(listView)
        env.router.show(listViewController, from: viewController, options: .modal(isDismissable: false, embedInNav: true, addDoneButton: false), analyticsRoute: "/file_progress")
    }
}

#if DEBUG

struct SubmitAssignmentExtensionView_Previews: PreviewProvider {

    static var previews: some View {
        let coursePickerViewModel = CoursePickerViewModel(state: .data([
            .init(id: "0", name: "American Literature"),
            .init(id: "1", name: "History"),
            .init(id: "2", name: "Math"),
            .init(id: "3", name: "Biology"),
        ]))

        let viewModel = SubmitAssignmentExtensionViewModel(coursePickerViewModel: coursePickerViewModel)
        SubmitAssignmentExtensionView(viewModel: viewModel)
    }
}

#endif
