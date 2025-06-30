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

extension InstUI {

    public struct RadioButtonCell<Value: Equatable>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        @Binding private var selectedValue: Value?
        private let title: String
        private let value: Value?
        private let dividerStyle: InstUI.Divider.Style

        /// - parameters:
        ///   - value: The value represented by this cell that will be passed to the `selectedValue` binding upon tap.
        ///   - selectedValue: This binding holds the currently selected value belonging to the radio button group. The value is equatable so this cell can decide when to display the selected state.
        public init(
            title: String,
            value: Value?,
            selectedValue: Binding<Value?>,
            dividerStyle: InstUI.Divider.Style = .full
        ) {
            self.title = title
            self.value = value
            self._selectedValue = selectedValue
            self.dividerStyle = dividerStyle
        }

        public var body: some View {
            let isSelected = value == selectedValue

            VStack(spacing: 0) {
                Button {
                    selectedValue = value
                } label: {
                    HStack(spacing: 0) {
                        InstUI.RadioButton(isSelected: isSelected)
                        .paddingStyle(.trailing, .cellIconText)
                        .animation(.default, value: selectedValue)

                        Text(title)
                            .textStyle(.cellLabel)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .paddingStyle(set: .iconCell)
                }
                .accessibilityLabel(Text(accessibilityLabel))
                .accessibilityRemoveTraits(.isButton)
                .accessibilityAddTraits(isSelected ? .isSelected : [])

                InstUI.Divider(dividerStyle)
            }
        }

        // This is a workaround to not having a `isRadioButton` trait.
        // The closing "." is needed to make VoiceOver read "Button" the same as with the trait.
        private var accessibilityLabel: String {
            let radioButton = String(localized: "Radio Button", bundle: .core, comment: "UI element type read out in VoiceOver.")
            return "\(title), \(radioButton)."
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var selectedValue: Int?

    VStack(spacing: 0) {
        InstUI.RadioButtonCell(
            title: "Value 1",
            value: 1,
            selectedValue: $selectedValue
        )
        InstUI.RadioButtonCell(
            title: "Value 2",
            value: 2,
            selectedValue: $selectedValue
        )
    }
}

#endif
