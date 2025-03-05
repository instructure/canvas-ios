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

    public struct SelectionMenuCell<Label, Value, ID>: View where Label: View, Value: Equatable, ID: Hashable {
        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Label
        private let options: [Value]

        private let idKey: KeyPath<Value, ID>
        private let textKey: KeyPath<Value, String>

        @Binding var selection: Value?

        init(label: Label,
             options: [Value],
             id: KeyPath<Value, ID>,
             text: KeyPath<Value, String>,
             selection: Binding<Value?>) {

            self.label = label
            self.options = options
            self.idKey = id
            self.textKey = text
            self._selection = selection
        }

        public var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
                    label.textStyle(.cellLabel)
                    Spacer()
                    selectionMenu
                }
                .paddingStyle(set: .standardCell)
                InstUI.Divider()
            }
        }

        @ViewBuilder
        private var selectionMenu: some View {
            SelectionMenu(
                options: options,
                id: idKey,
                text: textKey,
                selection: $selection)
        }
    }
}

extension InstUI.SelectionMenuCell where Value: Identifiable, ID == Value.ID {
    init(label: Label,
         options: [Value],
         text: KeyPath<Value, String>,
         selection: Binding<Value?>) {

        self.init(label: label,
                  options: options,
                  id: \.id,
                  text: text,
                  selection: selection)
    }
}

extension InstUI.SelectionMenuCell where Value: Identifiable, ID == Value.ID {
    init(label: Label,
         options: [Value],
         text: KeyPath<Value, String>,
         defaultValue: Value,
         selection: Binding<Value>) {
        self.init(label: label,
                  options: options,
                  id: \.id,
                  text: text,
                  defaultValue: defaultValue,
                  selection: selection)
    }
}

extension InstUI.SelectionMenuCell {

    init(label: Label,
         options: [Value],
         id: KeyPath<Value, ID>,
         text: KeyPath<Value, String>,
         defaultValue: Value,
         selection: Binding<Value>) {

        self.label = label
        self.options = options
        self.idKey = id
        self.textKey = text
        self._selection = Binding(
            get: {
                return selection.wrappedValue
            },
            set: { newValue in
                selection.wrappedValue = newValue ?? defaultValue
            }
        )
    }
}

#if DEBUG

#Preview {
    @Previewable @State var selection: String?

    return InstUI.SelectionMenuCell(
        label: Text(verbatim: "Example"),
        options: (1 ... 5).map { "No. \($0)" },
        id: \.self,
        text: \.self,
        selection: $selection)
}

#endif
