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

extension DropDownSelector {

    public init(
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        selection: Binding<Value>,
        prompt: String? = nil
    ) {

        let defaultValue = selection.wrappedValue

        self.init(
            choices: choices,
            id: id,
            title: title,
            selection: Binding(
                get: {
                    return [selection.wrappedValue]
                },
                set: { newList in
                    selection.wrappedValue = newList.first ?? defaultValue
                }
            ),
            multiSelection: false
        )
    }

    public init(
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        selection: Binding<Value?>,
        prompt: String? = nil
    ) {

        self.init(
            choices: choices,
            id: id,
            title: title,
            selection: Binding(
                get: {
                    return selection.wrappedValue.flatMap { [$0] } ?? []
                },
                set: { newList in
                    selection.wrappedValue = newList.first
                }
            ),
            multiSelection: false
        )
    }
}

extension DropDownSelector where Value: Equatable & Identifiable, Value.ID == ID {

    public init(
        choices: Choices,
        title: KeyPath<Value, String>,
        selection: Binding<[Value]>,
        prompt: String? = nil,
        multiSelection: Bool = true
    ) {

        self.init(
            choices: choices,
            id: \.id,
            title: title,
            selection: selection,
            prompt: prompt,
            multiSelection: multiSelection
        )
    }

    public init(
        choices: Choices,
        title: KeyPath<Value, String>,
        selection: Binding<Value>,
        prompt: String? = nil
    ) {

        let defaultValue = selection.wrappedValue

        self.init(
            choices: choices,
            id: \.id,
            title: title,
            selection: Binding(
                get: {
                    return [selection.wrappedValue]
                },
                set: { newList in
                    selection.wrappedValue = newList.first ?? defaultValue
                }
            ),
            prompt: prompt,
            multiSelection: false
        )
    }

    public init(
        choices: Choices,
        title: KeyPath<Value, String>,
        selection: Binding<Value?>,
        prompt: String? = nil
    ) {

        self.init(
            choices: choices,
            id: \.id,
            title: title,
            selection: Binding(
                get: {
                    return selection.wrappedValue.flatMap { [$0] } ?? []
                },
                set: { newList in
                    selection.wrappedValue = newList.first
                }
            ),
            prompt: prompt,
            multiSelection: false
        )
    }
}
