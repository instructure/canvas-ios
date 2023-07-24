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

public struct AssignmentPickerView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var viewModel: AssignmentPickerViewModel

    public init(viewModel: AssignmentPickerViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        content
            .navigationTitleStyled(Text("Select Assignment", bundle: .core).font(.semibold17).foregroundColor(.textDarkest))
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(viewModel.dismissViewDidTrigger) {
                presentationMode.wrappedValue.dismiss()
            }
            .alert(item: $viewModel.incompatibleFilesMessage, content: { item in
                Alert(title: Text("Incompatible File Type", bundle: .core), message: Text(item.message), dismissButton: .default(Text("OK", bundle: .core)))
            })
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        case .error(let message):
            error(message: message)
        case .data(let assignments):
            if assignments.isEmpty {
                error(message: NSLocalizedString("There are no active assignments in this course.", comment: ""))
            } else {
                self.assignments(assignments: assignments)
            }
        }
    }

    private func error(message: String) -> some View {
        Text(message)
            .font(.regular17)
            .foregroundColor(.textDarkest)
    }

    private func assignments(assignments: [AssignmentPickerItem]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(assignments) { item in
                    Button(action: { viewModel.assignmentSelected(item) }) {
                        HStack(spacing: 0) {
                            Text(item.name)
                                .font(.regular16)
                                .foregroundColor(.textDarkest)
                                .frame(height: 50)
                                .multilineTextAlignment(.leading)
                            Spacer()

                            if viewModel.selectedAssignment == item {
                                Image.checkSolid
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.electric)
                            } else if item.notAvailableReason != nil {
                                Image.noLine
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.textDarkest)
                            }
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 2)
                    }

                    Divider()
                }
            }
        }
    }
}

#if DEBUG

struct AssignmentPickerView_Previews: PreviewProvider {
    static var dataModel: AssignmentPickerViewModel {
        let dataModel = AssignmentPickerViewModel(state: .data([
            .init(id: "0", name: "American Literature"),
            .init(id: "1", name: "History"),
            .init(id: "2", name: "Math"),
            .init(id: "3", name: "Biology", notAvailableReason: "error"),
        ]))
        dataModel.assignmentSelected(.init(id: "2", name: "Math"))
        return dataModel
    }

    static var previews: some View {
        let loadingModel = AssignmentPickerViewModel(state: .loading)
        let errorModel = AssignmentPickerViewModel(state: .error("Something went wrong"))
        AssignmentPickerView(viewModel: dataModel)
            .previewLayout(.fixed(width: 300, height: 400))
        AssignmentPickerView(viewModel: dataModel)
            .previewLayout(.fixed(width: 300, height: 400))
            .preferredColorScheme(.dark)

        AssignmentPickerView(viewModel: loadingModel)
            .previewLayout(.fixed(width: 300, height: 400))
        AssignmentPickerView(viewModel: loadingModel)
            .previewLayout(.fixed(width: 300, height: 400))
            .preferredColorScheme(.dark)

        AssignmentPickerView(viewModel: errorModel)
            .previewLayout(.fixed(width: 300, height: 400))
        AssignmentPickerView(viewModel: errorModel)
            .previewLayout(.fixed(width: 300, height: 400))
            .preferredColorScheme(.dark)
    }
}

#endif
