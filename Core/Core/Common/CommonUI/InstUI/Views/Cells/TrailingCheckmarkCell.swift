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

extension InstUI {

    public struct TrailingCheckmarkCell<Value: Equatable>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        @Binding private var selectedValue: Value?
        private let title: String
        private let subtitle: String?
        private let value: Value?
        private let dividerStyle: InstUI.Divider.Style

        /// - parameters:
        ///   - value: The value represented by this cell that will be passed to the `selectedValue` binding upon tap.
        ///   - selectedValue: This binding holds the currently selected value belonging to the item picker group.
        ///                    The value is equatable so this cell can decide when to display the selected state.
        public init(
            title: String,
            subtitle: String? = nil,
            value: Value?,
            selectedValue: Binding<Value?>,
            dividerStyle: InstUI.Divider.Style = .full
        ) {
            self.title = title
            self.subtitle = subtitle
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
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title)
                                .textStyle(.cellLabel)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let subtitle {
                                Text(subtitle)
                                    .textStyle(.cellLabelSubtitle)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        if isSelected {
                            Image.checkSolid
                                .scaledIcon(size: 18)
                                .foregroundStyle(.tint)
                                .layoutPriority(1)
                                .paddingStyle(.leading, .cellAccessoryPadding)
                        }
                    }
                    .paddingStyle(set: .standardCell)
                }
                .accessibilityAddTraits(isSelected ? .isSelected : [])

                InstUI.Divider(dividerStyle)
            }
        }
    }
}

#if DEBUG

private struct Container: View {
    let selectedValue = 1

    var body: some View {
        VStack(spacing: 0) {
            InstUI.TrailingCheckmarkCell(
                title: "Value 1",
                value: 1,
                selectedValue: .constant(selectedValue)
            )
            .tint(.green)
            InstUI.TrailingCheckmarkCell(
                title: "Value 2",
                value: 2,
                selectedValue: .constant(selectedValue),
            )
        }
    }
}

#Preview {
    Container()
}

#endif
