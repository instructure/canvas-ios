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

public struct DropDownSelector<ID, Value, Choices>: View
where ID: Hashable,
      Value: Equatable,
      Choices: RandomAccessCollection,
      Choices.Element == Value {

    @State var state = DropDownButtonState()

    private let choices: Choices
    private let isMultiSelectionOn: Bool

    private let id: KeyPath<Value, ID>
    private let title: KeyPath<Value, String>
    private let prompt: String

    @Binding private var selection: [Value]

    public init(
        choices: Choices,
        id: KeyPath<Value, ID>,
        title: KeyPath<Value, String>,
        selection: Binding<[Value]>,
        prompt: String? = nil,
        multiSelection: Bool = true
    ) {
        self.choices = choices
        self.isMultiSelectionOn = multiSelection
        self.id = id
        self.title = title
        self.prompt = prompt ?? .defaultSelectionPrompt
        self._selection = selection
    }

    public var body: some View {
        DropDownButton(
            state: $state,
            label: {

                if isMultiSelectionOn {

                    if selection.isEmpty {
                        PromptLabel(prompt: prompt)
                    } else {
                        HStack(spacing: 8) {
                            ForEach(selection, id: id) { value in
                                SelectedLabel(text: value[keyPath: title])
                            }
                        }
                    }

                } else {
                    HStack {
                        let title = selection.first?[keyPath: title] ?? prompt
                        Text(title).font(.regular14)
                        InstUI.Icons.DropDown().foregroundStyle(Color.textDark)
                    }
                    .contentShape(Rectangle())
                }
            }
        )
        .fullScreenCover(isPresented: $state.isDetailsShown) {
            Color
                .clear
                .background(RemovalBackground())
                .dropDownSelectionListContainer(
                    state: $state,
                    choices: choices,
                    id: id,
                    title: title,
                    selection: $selection,
                    multiSelection: isMultiSelectionOn
                )
        }
        .transaction { transaction in
            // Unfortunately, we can't have animation for this setup,
            // this is to remove default animation fullScreenCover
            transaction.disablesAnimations = true
        }
    }
}

private struct PromptLabel: View {

    let prompt: String
    var body: some View {
        HStack(spacing: 7) {
            Text(prompt)
                .textStyle(.cellValue)
            InstUI.Icons.DropDown()
                .foregroundStyle(Color.textDark)
        }
        .paddingStyle(set: .selectionValueLabel)
        .contentShape(Rectangle())
    }
}

private struct SelectedLabel: View {

    let text: String
    var body: some View {
        Text(text)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .textStyle(.selectedValue)
            .paddingStyle(set: .selectionValueLabel)
            .background(Color.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

private struct RemovalBackground: UIViewRepresentable {
    private class RemovalView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }

    func makeUIView(context: UIViewRepresentableContext<RemovalBackground>) -> UIView {
        return RemovalView()
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<RemovalBackground>) {}
}

extension String {
    static var defaultSelectionPrompt: String {
        String(localized: "Not selected", bundle: .core)
    }
}

#if DEBUG

#Preview {

    struct PreviewView: View {

        @State var selectedWeekday: Weekday?

        var body: some View {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    DropDownSelector(
                        choices: Weekday.allCases,
                        id: \.rawValue,
                        title: \.text,
                        selection: $selectedWeekday
                    )
                    // Spacer()
                }
                .padding()
                Spacer()
            }
            .background(Color.mint)
        }
    }

    return PreviewView()
}

#endif
