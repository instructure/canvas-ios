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

    public struct ToggleCell<Label: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Label
        @Binding private var value: Bool

        public init(label: Label, value: Binding<Bool>) {
            self.label = label
            self._value = value
        }

        public var body: some View {
            VStack(spacing: 0) {
                InstUI.Toggle(isOn: $value) { label.allowsHitTesting(false) }
                    .textStyle(.cellLabel)
                    .paddingStyle(.leading, .standard)
                    .paddingStyle(.trailing, .standard)
                    // best effort estimations to match the height of other cells, correcting for Toggle
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                InstUI.Divider()
            }
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        InstUI.Divider()
        InstUI.ToggleCell(label: Text(verbatim: "Label"), value: .constant(false))
        InstUI.ToggleCell(label: Text(verbatim: "Label"), value: .constant(true))
        InstUI.LabelValueCell(label: Text(verbatim: "Label"), value: "Some value") { } // to compare height
        InstUI.ToggleCell(
            label: Text(verbatim: "Important label").foregroundStyle(Color.red).textStyle(.heading),
            value: .constant(false)
        )
    }
}

#endif
