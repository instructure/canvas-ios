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

    public struct SegmentedPicker<SelectionValue, Content>: View where SelectionValue: Hashable, Content: View {

        private var selection: Binding<SelectionValue>
        private let content: () -> Content

        public init(
            selection: Binding<SelectionValue>,
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.selection = selection
            self.content = content
            updateSegmentedControlAppearance()
        }

        public var body: some View {
            // Simply passing a string will be treated as a localized key
            // and will create an entry in the strings dictionary.
            Picker("" as String,
                   selection: selection.animation(.smooth(duration: 0.25)),
                   content: content
            )
            .pickerStyle(.segmented)
        }

        private func updateSegmentedControlAppearance() {
            // Segmented controls have a background image by default and colors we pass are applied to that image
            // with some opacity. Getting rid of the image is not that straightforward so we play around with the
            // colors to get a decent result for light and dark mode.
            let appearance = UISegmentedControl.appearance()
            appearance.backgroundColor = UIColor { traits in
                traits.isLightInterface ? .backgroundLightest : .backgroundLight
            }
            appearance.setTitleTextAttributes(
                [
                    .font: UIFont.scaledNamedFont(.semibold13),
                    .foregroundColor: UIColor.textDarkest
                ],
                for: .normal
            )
            // updateFontAppearance() overrides the selected state so we have to restore it
            appearance.setTitleTextAttributes(
                appearance.titleTextAttributes(for: .normal),
                for: .selected
            )
            appearance.selectedSegmentTintColor = .backgroundLightest
        }
    }
}

#if DEBUG

#Preview {
    @Previewable @State var selectedSegment = "one"

    InstUI.SegmentedPicker(
        selection: $selectedSegment
    ) {
        Text("One")
            .tag("one")
        Text("Two")
            .tag("two")
        Text("Three")
            .tag("three")
    }
}

#endif
