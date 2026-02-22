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
import Combine
import SwiftUI

struct SpeedGraderPickerCell: View {

    @StateObject var viewModel: SingleSelectionViewModel
    @Binding var isSaving: Bool

    private let title: String
    private let placeholder: String?
    private let identifierGroup: String?

    init(
        title: String,
        placeholder: String?,
        identifierGroup: String? = nil,
        allOptions: [OptionItem],
        selectOption: CurrentValueSubject<OptionItem?, Never>,
        didSelectOption: PassthroughSubject<OptionItem?, Never>,
        isSaving: Binding<Bool>
    ) {
        self.title = title
        self.placeholder = placeholder
        self.identifierGroup = identifierGroup
        self._isSaving = isSaving

        self._viewModel = StateObject(wrappedValue: .init(
            title: nil,
            allOptions: allOptions,
            selectedOption: selectOption,
            didSelectOption: didSelectOption
        ))
    }

    var body: some View {
        HStack(spacing: InstUI.Styles.Padding.cellAccessoryPadding.rawValue) {
            Text(title)
                .textStyle(.cellLabel)
                .frame(maxWidth: .infinity, alignment: .leading)

            picker.disabled(isSaving)
        }
        .paddingStyle(set: .standardCell)
        .background(Color.backgroundLightest)
        .accessibilityElement(children: .combine)
        // PickerMenu already has "Pop up button" trait.
        .accessibilityRemoveTraits(.isButton)
    }

    private var picker: some View {
        InstUI.PickerMenu(
            selectedOption: Binding(
                get: { viewModel.selectedOption },
                set: { viewModel.didSelectOption?.send($0) }
            ),
            allOptions: viewModel.allOptions,
            identifierGroup: identifierGroup,
            label: {
                Text(viewModel.selectedOption?.title ?? placeholder ?? "")
                    .font(.regular14, lineHeight: .fit)
                Image.dropdownLine
                    .scaledIcon(size: 24)
                    .accessibilityHidden(true)
            }
        )
        .animation(.none, value: viewModel.selectedOption?.title)
    }
}

#if DEBUG

#Preview {
    let statuses: [GradeStatus] = [
        .none,
        .excused,
        .late
    ]

    VStack(spacing: 20) {
        GradeStatusView(
            viewModel: .init(
                userId: "",
                submissionId: "",
                attempt: 0,
                interactor: GradeStatusInteractorPreview(gradeStatuses: statuses)
            )
        )
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#endif
