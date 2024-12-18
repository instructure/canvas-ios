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

    public struct CheckboxCell<Accessory: View>: View {

        // MARK: Private Properties

        @Environment(\.dynamicTypeSize) private var dynamicTypeSize

        private let title: String
        private let subtitle: String?
        @Binding private var isSelected: Bool
        private let color: Color
        private let accessoryView: (() -> Accessory)?
        private let dividerStyle: InstUI.Divider.Style

        // MARK: Initializers

        public init(
            title: String,
            subtitle: String? = nil,
            isSelected: Binding<Bool>,
            color: Color,
            accessoryView: (() -> Accessory)?,
            dividerStyle: InstUI.Divider.Style = .full
        ) {
            self.title = title
            self.subtitle = subtitle
            self._isSelected = isSelected
            self.color = color
            self.accessoryView = accessoryView
            self.dividerStyle = dividerStyle
        }

        public init(
            title: String,
            subtitle: String? = nil,
            isSelected: Binding<Bool>,
            color: Color,
            dividerStyle: InstUI.Divider.Style = .full
        ) where Accessory == SwiftUI.EmptyView {
            self.init(
                title: title,
                subtitle: subtitle,
                isSelected: isSelected,
                color: color,
                accessoryView: nil,
                dividerStyle: dividerStyle
            )
        }

        // MARK: Body

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

                        VStack(spacing: 2) {
                            Text(title)
                                .font(.regular16, lineHeight: .fit)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(Color.textDarkest)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let subtitle {
                                Text(subtitle)
                                    .font(.regular14, lineHeight: .fit)
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(Color.textDark)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        if let accessoryView {
                            Spacer()
                            accessoryView()
                        }
                    }
                    .paddingStyle(set: .iconCell)
                }
                InstUI.Divider(dividerStyle)
            }
            .accessibilityRepresentation {
                Toggle(isOn: $isSelected) {
                    Text(title)
                }
            }
        }
    }
}

#if DEBUG

private struct Container: View {
    @State var isSelected = false

    var body: some View {
        InstUI.CheckboxCell(
            title: "Checkbox here",
            subtitle: "Subtitle",
            isSelected: $isSelected,
            color: .orange
        )
    }
}

#Preview {
    Container()
}

#endif
