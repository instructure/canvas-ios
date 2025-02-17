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

public extension HorizonUI {
    struct Overlay: View {
        // MARK: - Dependencies

        private let title: String
        private let buttons: [ButtonAttribute]
        @Binding private var isPresented: Bool

        // MARK: - Init

        public init(
            title: String,
            buttons: [ButtonAttribute],
            isPresented: Binding<Bool>
        ) {
            self.title = title
            self.buttons = buttons
            self._isPresented = isPresented
        }

        public var body: some View {
            VStack(spacing: .huiSpaces.space24) {
                headerView
                options
                    .background(Color.huiColors.surface.cardPrimary)
                    .huiCornerRadius(level: .level3)
                    .padding(.horizontal, .huiSpaces.space16)
            }
            .padding(.vertical, .huiSpaces.space24)
            .padding(.horizontal, .huiSpaces.space16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.huiColors.primitives.beige11)
        }

        private var headerView: some View {
            ZStack(alignment: .trailing) {
                Text(title)
                    .foregroundStyle(Color.huiColors.primitives.grey125)
                    .huiTypography(.h3)
                    .frame(maxWidth: .infinity)
                HorizonUI.IconButton(HorizonUI.icons.close, type: .white) {
                    isPresented.toggle()
                }
                .huiElevation(level: .level2)
            }
            .padding(.horizontal, .huiSpaces.space16)
        }

        private var options: some View {
            VStack(spacing: .zero) {
                ForEach(buttons) { button in
                    Button {
                        button.onAction()
                    } label: {
                        buttonRow(button: button)
                    }
                    Divider()
                        .opacity(button.id == buttons.last?.id ? 0 : 1)
                }
            }
        }

        private func buttonRow(button: ButtonAttribute) -> some View {
            HStack {
                Text(button.title)
                    .huiTypography(.p1)
                Spacer()
                if let icon = button.icon {
                    icon
                        .resizable()
                        .frame(width: 24, height: 24)
                }

            }
            .padding(.horizontal, .huiSpaces.space16)
            .foregroundStyle(Color.huiColors.text.body)
            .padding(.vertical, .huiSpaces.space16)

        }
    }
}
public extension HorizonUI.Overlay {
    struct ButtonAttribute: Identifiable {
        public let id = UUID()
        let title: String
        let icon: Image?
        let onAction: () -> Void

        public init(
            title: String,
            icon: Image?,
            onAction: @escaping () -> Void
        ) {
            self.title = title
            self.icon = icon
            self.onAction = onAction
        }
    }
}

#Preview {
    HorizonUI
        .Overlay(
            title: "Title",
            buttons: [
                .init(title: "Choose Photo or Video",icon: Image.huiIcons.image) {
                    print("Choose Photo or Video")
                }
            ],
            isPresented: .constant(true)
        )
}
