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
            VStack(alignment: .leading) {
                Text("Course", bundle: .core)
                selectCourseButton
                divider
                Text("Assignment", bundle: .core)
                selectAssignmentButton
                divider
                HStack {
                    Text("Comment", bundle: .core)
                    Text("(Optional)", bundle: .core)
                }
                TextEditor(text: .constant("Enter comment"), maxHeight: 200)
                Spacer()
            }
            .navigationBarGlobal()
            .navigationBarTitleView(Text("Canvas Student", bundle: .core), displayMode: .inline)
            .compatibleNavBarItems(
                leading: { cancelButton },
                trailing: { submitButton }
            )
            .padding(16)
        }
    }

    private var selectCourseButton: some View {
        NavigationLink(destination: CoursePickerView(viewModel: viewModel.coursePickerViewModel, selectedCourse: $viewModel.selectedCourse)) {
            HStack {
                viewModel.selectCourseButtonTitle
                    .foregroundColor(.electric)
                Spacer()
                disclosureIndicator
            }
        }
        .frame(minHeight: 30)
    }

    private var divider: some View {
        Divider().padding(.horizontal, -16)
    }

    @ViewBuilder
    private var selectAssignmentButton: some View {
        if let assignmentViewModel = viewModel.assignmentPickerViewModel {
            let viewToPush = AssignmentPickerView(viewModel: assignmentViewModel, selectedAssignment: $viewModel.selectedAssignment)
            NavigationLink(destination: viewToPush) {
                HStack {
                    viewModel.selectAssignmentButtonTitle
                        .foregroundColor(.electric)
                    Spacer()
                    disclosureIndicator
                }
            }
            .frame(minHeight: 30)
        } else {
            HStack {
                Text("No course selected", bundle: .core)
                    .foregroundColor(.textDark)
                Spacer()
                disclosureIndicator
                    .opacity(0.5)
            }
            .frame(minHeight: 30)
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
        Button(action: {}) {
            Text("Cancel", bundle: .core)
                .foregroundColor(.electric)
        }
    }

    private var submitButton: some View {
        Button(action: {}) {
            Text("Submit", bundle: .core)
        }
        .disabled(viewModel.isSubmitButtonDisabled)
    }
}

#if DEBUG

struct SubmitAssignmentExtensionView_Previews: PreviewProvider {

    static var previews: some View {
        SubmitAssignmentExtensionView(viewModel: SubmitAssignmentExtensionViewModel())
    }
}

#endif
