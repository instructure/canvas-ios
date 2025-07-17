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
        private let identifierGroup: String?
        @Binding private var selectedOption: OptionItem?
        @AccessibilityFocusState private var isA11yFocused: Bool

        /// - parameters:
        ///   - identifierGroup: If specified, option items will have a11y identifiers in the form `<identifierGroup>.<option.id>`
        public init(
            selectedOption: Binding<OptionItem?>,
            allOptions: [OptionItem],
            identifierGroup: String? = nil,
            @ViewBuilder label: () -> Label
        ) {
            self._selectedOption = selectedOption
            self.allOptions = allOptions
            self.identifierGroup = identifierGroup
            self.label = label()
        }

        /// - parameters:
        ///   - identifierGroup: If specified, option items will have a11y identifiers in the form `<identifierGroup>.<option.id>`
        public init(
            selectedId: Binding<String?>,
            allOptions: [OptionItem],
            identifierGroup: String? = nil,
            @ViewBuilder label: () -> Label
        ) {
            self._selectedOption = Binding(
                get: { allOptions.option(with: selectedId.wrappedValue) },
                set: { selectedId.wrappedValue = $0?.id }
            )
            self.allOptions = allOptions
            self.identifierGroup = identifierGroup
            self.label = label()
        }

        /// - parameters:
        ///   - identifierGroup: If specified, option items will have a11y identifiers in the form `<identifierGroup>.<option.id>`
        public init(
            selectedId: Binding<Int>,
            allOptions: [OptionItem],
            identifierGroup: String? = nil,
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
            self.identifierGroup = identifierGroup
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
            .identifier(identifierGroup, option.id)
        }
    }
}

#if DEBUG

struct PickerMenuPreviews: PreviewProvider {
    static var previews: some View {
        @Previewable @State var basicSelection: OptionItem? = OptionItem(
            id: "option1",
            title: "Option 1"
        )
        @Previewable @State var subtitleSelection: OptionItem? = OptionItem(
            id: "red",
            title: "Red",
            subtitle: "Primary color"
        )
        @Previewable @State var iconSelection: OptionItem? = OptionItem(
            id: "star",
            title: "Favorite",
            accessoryIcon: Image(systemName: "star")
        )

        VStack(alignment: .leading, spacing: 0) {
            Text("Basic Options")
            InstUI.PickerMenu(
                selectedOption: $basicSelection,
                allOptions: [
                    OptionItem(id: "option1", title: "Option 1"),
                    OptionItem(id: "option2", title: "Option 2"),
                    OptionItem(id: "option3", title: "Option 3")
                ]
            ) {
                Text(basicSelection?.title ?? "Select option")
            }
            .padding(.bottom, 20)

            Text("With Subtitles")
            InstUI.PickerMenu(
                selectedOption: $subtitleSelection,
                allOptions: [
                    OptionItem(id: "red", title: "Red", subtitle: "Primary color"),
                    OptionItem(id: "blue", title: "Blue", subtitle: "Cool color"),
                    OptionItem(id: "green", title: "Green", subtitle: "Nature color")
                ]
            ) {
                Text(subtitleSelection?.title ?? "Select option")
            }
            .padding(.bottom, 20)

            Text("With Icons")
            InstUI.PickerMenu(
                selectedOption: $iconSelection,
                allOptions: [
                    OptionItem(id: "star", title: "Favorite", accessoryIcon: Image(systemName: "star")),
                    OptionItem(id: "heart", title: "Love", accessoryIcon: Image(systemName: "heart")),
                    OptionItem(id: "bookmark", title: "Saved", accessoryIcon: Image(systemName: "bookmark"))
                ]
            ) {
                Text(iconSelection?.title ?? "Select option")
            }
            .padding(.bottom, 20)
        }
    }
}

#endif
