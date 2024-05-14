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

    public struct CheckboxCell: View {
        private let name: String
        @Binding private var isSelected: Bool
        private let color: Color

        public init(name: String, isSelected: Binding<Bool>, color: Color) {
            self.name = name
            self._isSelected = isSelected
            self.color = color
        }

        public var body: some View {
            VStack(spacing: 0) {
                Button {
                    isSelected.toggle()
                } label: {
                    HStack(spacing: InstUI.Styles.Padding.cellIconText.rawValue) {
                        InstUI.Checkbox(
                            isSelected: isSelected,
                            color: color
                        )
                        .animation(.default, value: isSelected)
                        Text(name)
                            .font(.regular16, lineHeight: .fit)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Color.textDarkest)
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                    }
                    .paddingStyle(.leading, .cellLeading)
                    .paddingStyle(.trailing, .standard)
                    .paddingStyle(.top, .cellTop)
                    .paddingStyle(.bottom, .cellBottom)

                }
                InstUI.Divider()
            }
            .accessibilityAddTraits(traits)
        }

        private var traits: AccessibilityTraits {
            var traits = AccessibilityTraits()

            if #available(iOS 17.0, *) {
                _ = traits.insert([.isToggle])
            } else {
                _ = traits.insert(.isButton)
            }

            if isSelected {
                _ = traits.insert(.isSelected)
            }

            return traits
        }
    }
}

#if DEBUG

private struct Container: View {
    @State var isSelected = false

    var body: some View {
        InstUI.CheckboxCell(
            name: "Checkbox here",
            isSelected: $isSelected,
            color: .orange
        )
    }
}

#Preview {
    Container()
}

#endif
