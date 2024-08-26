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

    public struct PickerCell<Label, SelectionValue, Content>: View where Label: View, SelectionValue: Hashable, Content: View {

        public enum Style {
            case menu
            case segmented
        }

        private let label: Label
        @ViewBuilder private let content: () -> Content
        private let placeholder: String
        private let style: Style

        @Binding private var selection: SelectionValue

        public init(
            label: Label,
            @ViewBuilder content: @escaping () -> Content,
            selection: Binding<SelectionValue>,
            style: Style = .menu,
            placeholder: String?
        ) {

            self.label = label
            self.content = content
            self.style = style
            self.placeholder = placeholder ?? "No Selection".localized()
            self._selection = selection
        }

        public var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
                    label
                        .textStyle(.cellLabel)
                }
                .frame(minHeight: 36)
            }
            .paddingStyle(.leading, .standard)
            .paddingStyle(.trailing, .standard)
            // best effort estimations to match the height of other cells, correcting for DatePicker
            .padding(.top, 5)
            .padding(.bottom, 7)

            InstUI.Divider()
        }

        @ViewBuilder
        private var picker: some View {
            Picker(placeholder,
                   selection: $selection,
                   content: content)
            .pickerStyle(.menu)
        }
    }
}

#Preview {
    @State var selection: Int = 1

    return InstUI.PickerCell(
        label: Text("Example"),
        content: {
            Text("No 1").tag(1)
            Text("No 2").tag(2)
            Text("No 3").tag(3)
            Text("No 4").tag(4)

        },
        selection: $selection,
        placeholder: "Select Number")
}
