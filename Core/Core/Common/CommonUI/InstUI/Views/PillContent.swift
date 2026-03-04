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

extension InstUI {

    public struct PillContent: View {
        @ScaledMetric private var uiScale: CGFloat = 1

        private let title: String
        private let leadingIcon: Image?
        private let trailingIcon: Image?
        private let size: SizeConfig
        private let isTextBold: Bool

        public init(
            title: String,
            leadingIcon: Image? = nil,
            trailingIcon: Image? = nil,
            size: SizeConfig,
            isTextBold: Bool = false
        ) {
            self.title = title
            self.leadingIcon = leadingIcon
            self.trailingIcon = trailingIcon
            self.size = size
            self.isTextBold = isTextBold
        }

        public var body: some View {
            HStack(alignment: .center, spacing: size.iconTextSpacing) {
                leadingIcon?
                    .scaledIcon(size: size.iconSize)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.scaledNamedFont(isTextBold ? size.fontBold : size.font))
                    .multilineTextAlignment(.center)
                    .offset(y: -0.5) // Pushing the text up to make it more centered for the eye than real centering.

                trailingIcon?
                    .scaledIcon(size: size.iconSize)
                    .accessibilityHidden(true)
            }
            .applyTint()
            .padding(EdgeInsets(
                top: size.topPadding * uiScale,
                leading: leadingIcon != nil
                    ? size.iconHorizontalPadding * uiScale
                    : size.textHorizontalPadding * uiScale,
                bottom: size.bottomPadding * uiScale,
                trailing: trailingIcon != nil
                    ? size.iconHorizontalPadding * uiScale
                    : size.textHorizontalPadding * uiScale
            ))
            .frame(minHeight: size.height * uiScale)
        }
    }
}

// MARK: - Config

extension InstUI.PillContent {

    public struct SizeConfig {
        public let height: CGFloat
        public let font: UIFont.Name
        public let fontBold: UIFont.Name
        public let iconSize: CGFloat
        public let textHorizontalPadding: CGFloat
        public let iconHorizontalPadding: CGFloat
        public let iconTextSpacing: CGFloat
        public let topPadding: CGFloat
        public let bottomPadding: CGFloat

        private init(
            height: CGFloat,
            font: UIFont.Name,
            fontBold: UIFont.Name,
            iconSize: CGFloat,
            textHorizontalPadding: CGFloat,
            iconHorizontalPadding: CGFloat,
            iconTextSpacing: CGFloat,
            topPadding: CGFloat,
            bottomPadding: CGFloat
        ) {
            self.height = height
            self.font = font
            self.fontBold = fontBold
            self.iconSize = iconSize
            self.textHorizontalPadding = textHorizontalPadding
            self.iconHorizontalPadding = iconHorizontalPadding
            self.iconTextSpacing = iconTextSpacing
            self.topPadding = topPadding
            self.bottomPadding = bottomPadding
        }
    }
}

// MARK: - Config cases

extension InstUI.PillContent.SizeConfig {
    public static let height30: Self = .init(
        height: 30,
        font: .regular14,
        fontBold: .semibold14,
        iconSize: 16,
        textHorizontalPadding: 12,
        iconHorizontalPadding: 8,
        iconTextSpacing: 6,
        topPadding: 7,
        bottomPadding: 7
    )

    public static let height24: Self = .init(
        height: 24,
        font: .regular12,
        fontBold: .semibold12,
        iconSize: 14,
        textHorizontalPadding: 10,
        iconHorizontalPadding: 6,
        iconTextSpacing: 4,
        topPadding: 5,
        bottomPadding: 5
    )

    public static let height20: Self = .init(
        height: 20,
        font: .regular12,
        fontBold: .semibold12,
        iconSize: 14,
        textHorizontalPadding: 10,
        iconHorizontalPadding: 6,
        iconTextSpacing: 4,
        topPadding: 3,
        bottomPadding: 3
    )
}

#if DEBUG

#Preview {
    PillButtonStorybook()
}

#endif
