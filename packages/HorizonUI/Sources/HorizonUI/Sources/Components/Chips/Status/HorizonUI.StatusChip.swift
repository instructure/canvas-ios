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
    struct StatusChip: View {

        // MARK: - Propertites
        private let cornerRadius: CornerRadius = .level1

        // MARK: - Dependencies

        private let style: StatusChip.Style
        private let icon: Image?
        private let label: String?
        private let title: String
        private let isFilled: Bool
        private let hasBorder: Bool

        // MARK: - Init

        public init(
            title: String,
            style: StatusChip.Style,
            icon: Image? = nil,
            label: String? = nil,
            isFilled: Bool = true,
            hasBorder: Bool = false
        ) {
            self.style = style
            self.icon = icon
            self.label = label
            self.title = title
            self.isFilled = isFilled
            self.hasBorder = hasBorder
        }

        public var body: some View {
            HStack(spacing: .huiSpaces.space2) {
                if let icon = icon {
                    icon
                        .resizable()
                        .foregroundColor(style.iconColor(isFilled: isFilled))
                        .frame(width: 16, height: 16)
                }

                if let label = label {
                    Text(label)
                        .foregroundStyle(style.forgroundColor(isFilled: isFilled))
                        .huiTypography(.labelMediumBold)
                }

                Text(title)
                    .foregroundStyle(style.forgroundColor(isFilled: isFilled))
                    .huiTypography(.p2)
            }
            .padding(.horizontal, .huiSpaces.space8)
            .padding(.vertical, .huiSpaces.space2)
            .background(isFilled ? style.backgroundColor : Color.clear)
            .clipShape(.rect(cornerRadius: cornerRadius.attributes.radius))
            .overlay(
                RoundedRectangle(cornerRadius: hasBorder ? cornerRadius.attributes.radius : .zero)
                    .stroke(Color.huiColors.lineAndBorders.lineStroke, lineWidth: hasBorder ? 1 : .zero)
            )
        }
    }
}

#Preview {
    VStack {
        HorizonUI.StatusChip(
            title: "Title",
            style: .green,
            icon: Image.huiIcons.accountCircleFilled,
            label: "Lable",
            isFilled: true,
            hasBorder: false
        )

        HorizonUI.StatusChip(
            title: "Title",
            style: .gray,
            icon: Image.huiIcons.accountCircleFilled,
            label: nil,
            isFilled: true,
            hasBorder: true
        )
    }
}
