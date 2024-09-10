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

    public struct DropDownCell<Label: View, Value: View>: View {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize
        
        private let label: Label

        @ViewBuilder
        private let value: () -> Value

        @Binding var state: DropDownButtonState

        public init(label: Label,
                    state: Binding<DropDownButtonState>,
                    @ViewBuilder value: @escaping () -> Value) {
            self.label = label
            self._state = state
            self.value = value
        }

        public var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    label.textStyle(.cellLabel)
                    Spacer()
                    DropDownButton(state: $state, label: value)
                }
                .paddingStyle(set: .standardCell)
                InstUI.Divider()
            }
        }
    }
}

#if DEBUG

#Preview {
    InstUI.DropDownCell(label: Text(verbatim: "Repeats On"),
                        state: .constant(DropDownButtonState()),
                        value: { Text(verbatim: "Value") })
}

#endif
