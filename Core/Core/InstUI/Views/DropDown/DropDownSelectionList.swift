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

public struct DropDownSelectionList<ID, Value, Choices>: View
where ID: Hashable,
      Value: Equatable,
      Choices: RandomAccessCollection,
      Choices.Element == Value {

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let choices: Choices
    private let isMultiSelectionOn: Bool

    private let id: KeyPath<Value, ID>
    private let title: KeyPath<Value, String>

    @Binding var isPresented: Bool
    @Binding private var selection: [Value]

    public init(
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        isPresented: Binding<Bool>,
        selection: Binding<[Value]>,
        multiSelection: Bool
    ) {
        self.choices = choices
        self.id = id
        self.title = title
        self.isMultiSelectionOn = multiSelection
        self._isPresented = isPresented
        self._selection = selection
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(choices, id: id) { choice in
                    Button(
                        action: {
                            if isMultiSelectionOn {
                                selection.appendOrRemove(choice)
                            } else {
                                selection = [choice]
                                isPresented = false
                            }
                        },
                        label: {
                            HStack {
                                Text(choice[keyPath: title])
                                    .textStyle(.dropDownOption)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                InstUI.Icons.Checkmark()
                                    .foregroundStyle(Color.textDarkest)
                                    .layoutPriority(1)
                                    .hidden(selection.contains(choice) == false)
                            }
                            .paddingStyle(set: .standardCell)
                            .contentShape(Rectangle())
                        })
                    .buttonStyle(.plain)

                    if choices.last != choice {
                        InstUI.Divider()
                    }
                }
            }
            .frame(minWidth: 260)
            .fixedSize()
            .preferredAsDropDownDetails()
        }
        .onTapGesture { } // Fixes an issue with tappable area of first and last buttons.
    }
}

#if DEBUG

#Preview {

    struct PreviewView: View {

        @State var selectedWeekday: Weekday?

        var body: some View {
            DropDownSelectionList(
                choices: Weekday.allCases,
                id: \.rawValue,
                title: \.text,
                isPresented: .constant(true),
                selection: $selectedWeekday
            )
        }
    }

    return PreviewView()
}

#endif
