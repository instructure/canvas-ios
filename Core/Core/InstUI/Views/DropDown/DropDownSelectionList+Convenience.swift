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

// MARK: - Convenience Initializers

extension DropDownSelectionList {

    public init(
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        isPresented: Binding<Bool>,
        selection: Binding<Value>
    ) {

        let defaultValue = selection.wrappedValue

        self.init(
            choices: choices,
            id: id,
            title: title,
            isPresented: isPresented,
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
        isPresented: Binding<Bool>,
        selection: Binding<Value?>
    ) {

        self.init(
            choices: choices,
            id: id,
            title: title,
            isPresented: isPresented,
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

// MARK: - View Modifiers

public extension View {

    func dropDownSelectionListContainer<ID, Value, Choices>(
        state: Binding<DropDownButtonState>,
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        selection: Binding<[Value]>,
        multiSelection: Bool = true
    ) -> some View
    where ID: Hashable,
          Value: Equatable,
          Choices: RandomAccessCollection,
          Choices.Element == Value {

              modifier(
                DropDownDetailsContainerViewModifier(
                    state: state,
                    detailsContent: {
                        DropDownSelectionList(
                            choices: choices,
                            id: id,
                            title: title,
                            isPresented: state.isDetailsShown,
                            selection: selection,
                            multiSelection: multiSelection
                        )
                    }
                )
              )
          }

    func dropDownSelectionListContainer<ID, Value, Choices>(
        state: Binding<DropDownButtonState>,
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        selection: Binding<Value>
    ) -> some View
    where ID: Hashable,
          Value: Equatable,
          Choices: RandomAccessCollection,
          Choices.Element == Value {

              modifier(
                DropDownDetailsContainerViewModifier(
                    state: state,
                    detailsContent: {
                        DropDownSelectionList(
                            choices: choices,
                            id: id,
                            title: title,
                            isPresented: state.isDetailsShown,
                            selection: selection
                        )
                    }
                )
              )
          }

    func dropDownSelectionListContainer<ID, Value, Choices>(
        state: Binding<DropDownButtonState>,
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        selection: Binding<Value?>
    ) -> some View
    where ID: Hashable,
          Value: Equatable,
          Choices: RandomAccessCollection,
          Choices.Element == Value {

              modifier(
                DropDownDetailsContainerViewModifier(
                    state: state,
                    detailsContent: {
                        DropDownSelectionList(
                            choices: choices,
                            id: id,
                            title: title,
                            isPresented: state.isDetailsShown,
                            selection: selection
                        )
                    }
                )
              )
          }
}

// MARK: - Identifiable Conveniences

public extension View {

    func dropDownSelectionListContainer<ID, Value, Choices>(
        state: Binding<DropDownButtonState>,
        choices: Choices,
        title: KeyPath<Value, String>,
        selection: Binding<[Value]>,
        multiSelection: Bool
    ) -> some View
    where Value: Equatable & Identifiable,
          Choices: RandomAccessCollection,
          Choices.Element == Value {

              modifier(
                DropDownDetailsContainerViewModifier(
                    state: state,
                    detailsContent: {
                        DropDownSelectionList(
                            choices: choices,
                            id: \Value.id,
                            title: title,
                            isPresented: state.isDetailsShown,
                            selection: selection,
                            multiSelection: multiSelection
                        )
                    }
                )
              )
          }

    func dropDownSelectionListContainer<ID, Value, Choices>(
        state: Binding<DropDownButtonState>,
        choices: Choices,
        title: KeyPath<Value, String>,
        selection: Binding<Value>
    ) -> some View
    where Value: Equatable & Identifiable,
          Choices: RandomAccessCollection,
          Choices.Element == Value {

              modifier(
                DropDownDetailsContainerViewModifier(
                    state: state,
                    detailsContent: {
                        DropDownSelectionList(
                            choices: choices,
                            id: \Value.id,
                            title: title,
                            isPresented: state.isDetailsShown,
                            selection: selection
                        )
                    }
                )
              )
          }

    func dropDownSelectionListContainer<ID, Value, Choices>(
        state: Binding<DropDownButtonState>,
        choices: Choices,
        title: KeyPath<Value, String>,
        selection: Binding<Value?>
    ) -> some View
    where Value: Equatable & Identifiable,
          Choices: RandomAccessCollection,
          Choices.Element == Value {

              modifier(
                DropDownDetailsContainerViewModifier(
                    state: state,
                    detailsContent: {
                        DropDownSelectionList(
                            choices: choices,
                            id: \Value.id,
                            title: title,
                            isPresented: state.isDetailsShown,
                            selection: selection
                        )
                    }
                )
              )
          }
}
