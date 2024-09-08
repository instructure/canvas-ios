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

struct SelectionMenu<Value: Equatable, ID: Hashable>: View {

    private let options: [Value]
    private let idKey: KeyPath<Value, ID>
    private let textKey: KeyPath<Value, String>

    @Binding var selection: Value?

    init(options: [Value],
         id: KeyPath<Value, ID>,
         text: KeyPath<Value, String>,
         selection: Binding<Value?>) {

        self.options = options
        self.idKey = id
        self.textKey = text
        self._selection = selection
    }

    var body: some View {
        Menu {
            ForEach(options, id: idKey) { op in
                Button {
                    selection = op
                } label: {
                    HStack {
                        Text(op[keyPath: textKey])
                            .font(.regular14)
                        if selection == op {
                            Image.checkLine
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(title).font(.regular14)
                InstUI.Icons.DropDown().foregroundStyle(Color.textDark)
            }
            .paddingStyle(set: .selectionValueLabel)
            .contentShape(Rectangle())
        }
        .tint(Color.textDark)
    }

    private var title: String {
        return selection?[keyPath: textKey]
            ?? String(localized: "Not selected", bundle: .core)
    }
}

extension SelectionMenu where Value: Identifiable, ID == Value.ID {
    init(options: [Value],
         text: KeyPath<Value, String>,
         selection: Binding<Value?>) {

        self.options = options
        self.idKey = \.id
        self.textKey = text
        self._selection = selection
    }
}

#if DEBUG

#Preview {
    struct PreviewView: View {
        @State var selection: String?

        var body: some View {
            SelectionMenu(
                options: [
                    "One", "Two", "Three", "Four"
                ],
                id: \.self,
                text: \.self,
                selection: $selection)
        }
    }
    return PreviewView()
}

#endif
