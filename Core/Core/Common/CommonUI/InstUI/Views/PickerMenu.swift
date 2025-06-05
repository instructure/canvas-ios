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

import SwiftUI

extension InstUI {

    public struct PickerMenu<Label: View>: View {

        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let label: Label
        private let allOptions: [OptionItem]
        @Binding private var selectedOption: OptionItem?
        @AccessibilityFocusState private var isA11yFocused: Bool

        public init(
            selectedOption: Binding<OptionItem?>,
            allOptions: [OptionItem],
            @ViewBuilder label: () -> Label
        ) {
            self._selectedOption = selectedOption
            self.allOptions = allOptions
            self.label = label()
        }

        public init(
            selectedId: Binding<String?>,
            allOptions: [OptionItem],
            @ViewBuilder label: () -> Label
        ) {
            self._selectedOption = Binding(
                get: { allOptions.option(with: selectedId.wrappedValue) },
                set: { selectedId.wrappedValue = $0?.id }
            )
            self.allOptions = allOptions
            self.label = label()
        }

        public init(
            selectedId: Binding<Int>,
            allOptions: [OptionItem],
            @ViewBuilder label: () -> Label
        ) {
            self._selectedOption = Binding(
                get: { allOptions.option(with: String(selectedId.wrappedValue)) },
                set: { newOption in
                    guard let newOption, let newId = Int(newOption.id) else { return }
                    selectedId.wrappedValue = newId
                }
            )
            self.allOptions = allOptions
            self.label = label()
        }

        public var body: some View {
            Menu(
                content: {
                    Picker(
                        selection: $selectedOption,
                        content: {
                            ForEach(allOptions) { option in
                                menuItem(for: option)
                                    .tag(option)
                            }
                        },
                        label: { }
                    )
                },
                label: { label }
            )
            .onChange(of: selectedOption) {
                isA11yFocused = true
            }
            .accessibilityRemoveTraits(.isButton) // It would read "Button, Pop up button" otherwise
            .accessibilityRefocusingOnPopoverDismissal()
            .accessibilityFocused($isA11yFocused)
        }

        private func menuItem(for option: OptionItem) -> some View {
            Button(action: {}) {
                Text(option.title)
                if let subtitle = option.subtitle {
                    Text(subtitle)
                }
                if let accessoryIcon = option.accessoryIcon {
                    accessoryIcon
                }
            }
            .accessibilityLabel(
                option.customAccessibilityLabel
                    ?? [option.title, option.subtitle].joined(separator: ", ")
            )
        }
    }
}
