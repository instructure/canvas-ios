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

import SwiftUI

public struct SubmitAssignmentExtensionView: View {
    @ObservedObject private var viewModel: SubmitAssignmentExtensionViewModel

    public init(viewModel: SubmitAssignmentExtensionViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                selectCourseButton
                divider
                selectAssignmentButton
                commentBox
                divider
                Spacer()
            }
            .navigationBarGlobal()
            .navigationBarTitleView(Text("Canvas Student", bundle: .core).font(.semibold17).foregroundColor(.textDarkest), displayMode: .inline)
            .compatibleNavBarItems(
                leading: { cancelButton },
                trailing: { submitButton }
            )
            .padding(.horizontal, 20)
        }
    }

    private var commentBox: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.comment.isEmpty {
                Text("Add comment (optional)", comment: "")
                    .foregroundColor(.textDark)
                    .font(.regular16)
                    .padding(.top, 20)
            }

            TextEditor(text: $viewModel.comment, maxHeight: 200)
                .foregroundColor(.textDarkest)
                .font(.regular16)
                .padding(.vertical, 20)
        }
    }

    private var selectCourseButton: some View {
        NavigationLink(destination: CoursePickerView(viewModel: viewModel.coursePickerViewModel, selectedCourse: $viewModel.selectedCourse)) {
            HStack {
                viewModel.selectCourseButtonTitle
                    .foregroundColor(viewModel.selectedCourse == nil ? .textDark : .textDarkest)
                    .font(.regular16)
                Spacer()
                disclosureIndicator
            }
        }
        .frame(height: 54)
    }

    private var divider: some View {
        Divider().padding(.horizontal, -20)
    }

    @ViewBuilder
    private var selectAssignmentButton: some View {
        if let assignmentViewModel = viewModel.assignmentPickerViewModel {
            let viewToPush = AssignmentPickerView(viewModel: assignmentViewModel, selectedAssignment: $viewModel.selectedAssignment)
            NavigationLink(destination: viewToPush) {
                VStack(spacing: 0) {
                    HStack {
                        viewModel.selectAssignmentButtonTitle
                            .foregroundColor(viewModel.selectedAssignment == nil ? .textDark : .textDarkest)
                            .font(.regular16)
                        Spacer()
                        disclosureIndicator
                    }
                        .frame(height: 54)
                    divider
                }
            }
        }
    }

    private var disclosureIndicator: some View {
        Image.arrowOpenRightSolid
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(.ash)
            .padding(.leading, 10)
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
            CircleProgress(size: 20)
        } else {
            Button(action: viewModel.submitTapped) {
                Text("Submit", bundle: .core)
                    .font(.semibold17)
            }
            .disabled(viewModel.isSubmitButtonDisabled)
        }
    }
}

#if DEBUG

struct SubmitAssignmentExtensionView_Previews: PreviewProvider {

    static var previews: some View {
        let coursePickerViewModel = CoursePickerViewModel(data: .courses([
            .init(id: "0", name: "American Literature"),
            .init(id: "1", name: "History"),
            .init(id: "2", name: "Math"),
            .init(id: "3", name: "Biology"),
        ]))

        let viewModel = SubmitAssignmentExtensionViewModel(coursePickerViewModel: coursePickerViewModel)
        SubmitAssignmentExtensionView(viewModel: viewModel)
            .previewDevice(PreviewDevice(stringLiteral: "iPhone 12"))
    }
}

#endif
