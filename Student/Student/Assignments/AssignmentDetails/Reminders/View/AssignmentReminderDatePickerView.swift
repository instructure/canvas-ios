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
import Combine
import SwiftUI

struct AssignmentReminderDatePickerView: View {
    @Environment(\.viewController) private var viewController
    @StateObject private var viewModel: AssignmentReminderDatePickerViewModel

    init(viewModel: @escaping () -> AssignmentReminderDatePickerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.buttonTitles, id: \.self) {
                    button(title: $0)
                    divider
                }

                customIntervalPicker
                    .frame(height: viewModel.customPickerVisible ? nil : 0)
                    .opacity(viewModel.customPickerVisible ? 1 : 0)
            }
            .animation(.default, value: viewModel.customPickerVisible)
        }
        .background(Color.backgroundLightest)
        .navigationTitle(Text("Reminder"))
        .navBarItems(leading: cancelButton, trailing: doneButton)
    }

    private func button(title: String) -> some View {
        Button {
            viewModel.buttonDidTap(title: title)
        } label: {
            HStack(spacing: 0) {
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.regular14)
                if viewModel.selectedButton == title {
                    Image.checkLine
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .foregroundStyle(Color.textDarkest)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .background(Color.backgroundLightest)
        }
        .animation(.none, value: viewModel.customPickerVisible)
    }

    private var divider: some View {
        Color.borderMedium.frame(height: 0.5)
    }

    @ViewBuilder
    private var customIntervalPicker: some View {
        HStack(spacing: 0) {
            Picker(selection: $viewModel.customValue) {
                ForEach(viewModel.customValues, id: \.self) {
                    Text(verbatim: "\($0)").tag($0)
                }
            } label: {

            }
            .pickerStyle(WheelPickerStyle())
            Picker(selection: $viewModel.customMetric) {
                ForEach(AssignmentReminderDatePickerViewModel.Metric.allCases) {
                    Text($0.pickerTitle).tag($0)
                }
            } label: {}
            .pickerStyle(WheelPickerStyle())
        }
        .font(.regular16)
        .foregroundStyle(Color.textDarkest)
        divider
    }

    private var cancelButton: some View {
        Button {
            viewController.value.dismiss(animated: true)
        } label: {
            Text("Cancel")
                .font(.regular16)
                .foregroundStyle(Color(Brand.shared.primary))
        }
    }

    private var doneButton: some View {
        Button {
            viewModel.doneButtonDidTap()
        } label: {
            Text("Done")
                .font(.regular16)
                .foregroundStyle(Color(Brand.shared.primary))
                .opacity(viewModel.doneButtonActive ? 1 : 0.3)
        }
        .disabled(!viewModel.doneButtonActive)
        .animation(.default, value: viewModel.doneButtonActive)
    }
}

#if DEBUG

struct AssignmentReminderDatePickerView_Previews: PreviewProvider {

    @ViewBuilder
    static var previews: some View {
        let viewModel = AssignmentReminderDatePickerViewModel(assignmentDate: .now,
                                                              selectedReminderDate: PassthroughSubject<Date, Never>())
        AssignmentReminderDatePickerView(viewModel: { viewModel })
    }
}

#endif
