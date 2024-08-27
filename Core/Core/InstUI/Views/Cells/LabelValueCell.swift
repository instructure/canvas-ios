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
        private let action: () -> Void

        public init(label: Label, value: String?, equalWidth: Bool = true, action: @escaping () -> Void) {
            self.label = label
            self.value = value
            self.equalWidth = equalWidth
            self.action = action
        }

        public var body: some View {
            VStack(spacing: 0) {
                Button(action: action) {
                    HStack(spacing: 0) {

                        if equalWidth {
                            labelView
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .paddingStyle(.trailing, .standard)
                            valueView.frame(maxWidth: .infinity, alignment: .trailing)
                        } else {
                            labelView
                            Spacer()
                            valueView
                        }

                        InstUI.DisclosureIndicator()
                            .padding(.leading, InstUI.DisclosureIndicator.leadingPadding)
                    }
                    .paddingStyle(set: .standardCell)
                    .contentShape(Rectangle())
                }

                InstUI.Divider()
            }
        }

        private var labelView: some View {
            label.textStyle(.cellLabel)
        }

        private var valueView: some View {
            Text(value ?? "")
                .textStyle(.cellValue)
                .multilineTextAlignment(.trailing)
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
