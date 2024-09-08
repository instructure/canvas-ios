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

    public struct LabelValueCell<Label: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Label
        private let value: String?
        private let equalWidth: Bool
        private let action: (() -> Void)?

        /// Initializes a Label & View cell.
        ///
        /// - Parameters:
        ///   - label: A view to show on the leading edge of the cell. Indicating the label of a value.
        ///   - value: A text value to show on the trailing edge of the cell.
        ///   - equalWidth: If `true`, label & value views are given equal widths with (leading, trailing) alignment respectively. Otherwise both of them are given their ideal sizes with a `Spacer()` in between to fill in the container view.
        ///   - action: A closure to call when cell is tapped.
        ///   
        public init(
            label: Label,
            value: String?,
            equalWidth: Bool = true,
            action: (() -> Void)? = nil
        ) {
            self.label = label
            self.value = value
            self.equalWidth = equalWidth
            self.action = action
        }

        public var body: some View {
            VStack(spacing: 0) {
                Button(action: { action?() }) {
                    HStack(spacing: 0) {
                        label
                            .textStyle(.cellLabel)

                        Spacer()

                        Text(value ?? "")
                            .textStyle(.cellValue)
                            .multilineTextAlignment(.trailing)

                        if action != nil {
                            InstUI.DisclosureIndicator()
                                .padding(.leading, InstUI.DisclosureIndicator.leadingPadding)
                        }
                    }
                    .paddingStyle(set: .standardCell)
                    .contentShape(Rectangle())
                }
                .disabled(action == nil)

                InstUI.Divider()
            }
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        InstUI.Divider()
        InstUI.LabelValueCell(label: Text(verbatim: "Label"), value: nil) {
            print("Did tap cell 1")
        }
        InstUI.LabelValueCell(label: Text(verbatim: "Label"), value: "Some value") {
            print("Did tap cell 2")
        }
        InstUI.LabelValueCell(
            label: Text(verbatim: "Important label").foregroundStyle(Color.red).textStyle(.heading),
            value: "Some value"
        ) {
            print("Did tap cell 3")
        }
    }
}

#endif
