//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public extension HorizonUI {
    struct Search: View {
        // MARK: - Private variables

        @FocusState private var isFocused: Bool

        // MARK: - Dependencies

        @Binding private var text: String
        private let placeholder: String
        private let size: HorizonUI.Search.Size
        private let hasCancelButton: Bool

        // MARK: - Init

       public init(
            text: Binding<String>,
            placeholder: String,
            size: HorizonUI.Search.Size,
            hasCancelButton: Bool = false
        ) {
            _text = text
            self.placeholder = placeholder
            self.size = size
            self.hasCancelButton = hasCancelButton
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.space8) {
                searchImage
                textField
                if hasCancelButton {
                    cancelButton
                }
            }
            .padding(.horizontal, .huiSpaces.space16)
            .frame(height: size.height)
            .background(Capsule().fill(Color.huiColors.surface.cardPrimary))
            .overlay(
                Capsule().stroke(
                    isFocused ?
                    Color.huiColors.surface.institution
                    : Color.huiColors.lineAndBorders.containerStroke,
                    lineWidth: isFocused ? 2 : 1.2
                )
            )
        }

        private var searchImage: some View {
            Image.huiIcons.search
                .foregroundStyle(Color.huiColors.icon.light)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
        }

        private var textField: some View {
            TextField(
                "",
                text: $text,
                prompt:
                    Text(placeholder)
                    .foregroundColor(.huiColors.text.placeholder)
                )
            .huiTypography(.p1)
            .foregroundColor(.huiColors.text.title)
            .focused($isFocused)
        }

        private var cancelButton: some View {
            Button {
                text = ""
            } label: {
                Image.huiIcons.cancel
                    .foregroundStyle(Color.huiColors.text.placeholder)
                    .frame(width: size.iconSize, height: size.iconSize)
            }
        }
    }
}

#Preview {
    @Previewable @State var text: String = ""
    VStack {
        HorizonUI.Search(text: $text, placeholder: "Search", size: .medium, hasCancelButton: true)
        HorizonUI.Search(text: $text, placeholder: "Search", size: .large, hasCancelButton: false)
        HorizonUI.Search(text: $text, placeholder: "Search", size: .small, hasCancelButton: true)
    }
    .padding()
}
