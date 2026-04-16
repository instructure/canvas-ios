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

extension AUI {

    public struct ToggleCell<Label: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Label
        @Binding private var value: Bool
        private let dividerStyle: AUI.Divider.Style

        public init(
            label: Label,
            value: Binding<Bool>,
            dividerStyle: AUI.Divider.Style = .full
        ) {
            self.label = label
            self._value = value
            self.dividerStyle = dividerStyle
        }

        public var body: some View {
            VStack(spacing: 0) {
                AUI.Toggle(isOn: $value) { label.allowsHitTesting(false) }
                    .textStyle(.cellLabel)
                    .paddingStyle(.leading, .standard)
                    .paddingStyle(.trailing, .standard)
                    // best effort estimations to match the height of other cells, correcting for Toggle
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                AUI.Divider(dividerStyle)
            }
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        AUI.Divider()
        AUI.ToggleCell(label: Text(verbatim: "Label"), value: .constant(false))
        AUI.ToggleCell(label: Text(verbatim: "Label"), value: .constant(true))
        AUI.LabelValueCell(label: Text(verbatim: "Label"), value: "Some value") { } // to compare height
        AUI.ToggleCell(
            label: Text(verbatim: "Important label").foregroundStyle(Color.red).textStyle(.heading),
            value: .constant(false)
        )
    }
}

#endif
