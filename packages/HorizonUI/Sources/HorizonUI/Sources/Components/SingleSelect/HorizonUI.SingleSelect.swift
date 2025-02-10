//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Observation
import SwiftUI

extension HorizonUI {
    public struct SingleSelect<Content: View>: View {

        // MARK: Dependencies

        private let content: Content?
        private let label: String?
        private let options: [String]
        @Binding private var selection: String

        // MARK: Properties

        private var originalSelection: String
        @State private var text: String = ""
        @State private var open: Bool = false
        @FocusState private var focused: Bool
        @State private var filteredItems: [String] = []

        // MARK: - Init

        public init(
            label: String? = nil,
            selection: Binding<String>,
            options: [String],
            @ViewBuilder content: (() -> Content)
        ) {
            self.label = label
            self.options = options
            self._selection = selection
            self.content = content()

            originalSelection = selection.wrappedValue
            text = selection.wrappedValue
            filteredItems = options
        }

        public var body: some View {
            ZStack(alignment: .top) {
                VStack(spacing: 8) {
                    textInput
                    content
                }
                displayedOptions
            }
            .padding(.vertical, 25)
        }

        // MARK: - Private

        @ViewBuilder
        private var displayedOptions: some View {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: .zero) {
                        ForEach(filteredItems, id: \.self) { item in
                            displayedOption(item)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.huiColors.surface.pageSecondary)
                    .padding(.vertical, .huiSpaces.primitives.xxSmall)
                    .padding(.horizontal, 5)
                }
                .background(Color.huiColors.surface.pageSecondary)
                .cornerRadius(12)
                .shadow(radius: 3)
                .offset(y: 90)
                .frame(maxHeight: min(geometry.size.height, 300), alignment: .leading)
                .opacity(open ? 1 : 0)
                .animation(.easeInOut, value: open)
                .padding(.horizontal, .huiSpaces.primitives.xxSmall)
            }
        }

        private func displayedOption(_ text: String) -> some View {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .huiSpaces.primitives.small)
                .padding(.vertical, .huiSpaces.primitives.xSmall)
                .background(Color.huiColors.surface.pageSecondary)
                .huiTypography(.p1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    focused = false
                    self.selection = text
                    self.text = text
                }
        }

        @ViewBuilder
        private var textInput: some View {
            HorizonUI.TextInput(
                $text,
                label: label,
                trailing: Image.huiIcons.chevronRight.rotationEffect(.degrees(open ? -90 : 90)).animation(
                    .easeInOut, value: open),
                focused: _focused
            )
            .onChange(of: focused, onFocusChange)
            .onChange(of: text, onTextChange)
        }

        // MARK: - Private Actions

        private func onFocusChange(oldValue: Bool, newValue: Bool) {
            if newValue {
                filteredItems = options
            } else {
                let firstMatch = options.first { $0.lowercased() == text.lowercased() }
                if firstMatch == nil {
                    selection = originalSelection
                    text = originalSelection
                }
            }

            open = newValue
        }

        private func onTextChange(oldValue: String, newValue: String) {
            if !focused {
                return
            }

            // If the text input is empty, display all items
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                filteredItems = options
                return
            }

            // Display only the items that match what the user's input
            filteredItems = options.filter { $0.lowercased().contains(text.lowercased()) }

            // If what they've typed leaves no filtered items, display all options
            if filteredItems.isEmpty {
                filteredItems = options
            }
        }

    }
}

#Preview {

    @Previewable @State var selection = ""

    HorizonUI.SingleSelect(
        selection: $selection,
        options: ["Alphabet", "Backyard", "Country"]
    ) {}
}
