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

public extension HorizonUI {
    struct Tag: View {
        public enum Size {
            case small
            case medium
            case large

            var typography: Typography.Name {
                switch self {
                case .small: return .p3
                case .medium: return .buttonTextMedium
                case .large: return .buttonTextLarge
                }
            }
        }

        public enum Style {
            case standalone
            case inline

            var cornerRadius: CornerRadius {
                switch self {
                case .standalone:
                    return .level5
                case .inline:
                    return .level1
                }
            }
        }

        // MARK: - Dependencies

        private let title: String
        private let style: Style
        private let size: Size
        private let backgroundColor: Color
        private let borderColor: Color
        private let onCloseAction: (() -> Void)?

        // MARK: - Init

        init(
            title: String,
            style: Style,
            size: Size,
            backgroundColor: Color = .huiColors.surface.pageSecondary,
            borderColor: Color = .huiColors.lineAndBorders.lineStroke,
            onCloseAction: (() -> Void)? = nil
        ) {
            self.title = title
            self.style = style
            self.size = size
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.onCloseAction = onCloseAction
        }

        public var body: some View {
            switch style {
            case .standalone:
                standaloneTag
            case .inline:
                inlineTag
            }
        }

        private var inlineTag: some View {
            ZStack(alignment: .topTrailing) {
                Text(title).huiTypography(size.typography)
                    .padding(.leading, leadingPadding())
                    .padding(.trailing, trailingPadding())
                    .padding(.vertical, verticalPadding())
                    .frame(minHeight: minimumHeight())
                    .fixedSize(horizontal: false, vertical: false)
                    .huiCornerRadius(level: style.cornerRadius)
                    .huiBorder(
                        level: .level1,
                        color: borderColor,
                        radius: style.cornerRadius.attributes.radius
                    )

                if let onCloseAction {
                    // TODO: Use Badge component
                    Button {
                        onCloseAction()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 19, height: 19)
                            .foregroundColor(.huiColors.surface.institution)
                            .background(Circle().fill(Color.huiColors.icon.surfaceColored))
                            .offset(x: 9.5, y: -9.5)
                    }
                }
            }
        }

        private var standaloneTag: some View {
            HStack(spacing: .huiSpaces.primitives.xxxSmall) {
                Text(title).huiTypography(size.typography)

                if let onCloseAction {
                    Button {
                        onCloseAction()
                    } label: {
                        Image.huiIcons.close
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(.leading, leadingPadding())
            .padding(.trailing, trailingPadding())
            .padding(.vertical, verticalPadding())
            .frame(minHeight: minimumHeight())
            .fixedSize(horizontal: false, vertical: false)
            .huiCornerRadius(level: style.cornerRadius)
            .huiBorder(
                level: .level1,
                color: borderColor,
                radius: style.cornerRadius.attributes.radius
            )
        }

        // MARK: - Helpers

        private func leadingPadding() -> CGFloat {
            switch (style, size) {
            case (.standalone, .large):
                return onCloseAction != nil
                    ? CGFloat.huiSpaces.primitives.mediumSmall
                    : CGFloat.huiSpaces.primitives.small
            case (.standalone, .medium):
                return onCloseAction != nil
                    ? CGFloat.huiSpaces.primitives.small
                    : CGFloat.huiSpaces.primitives.xSmall
            case (.standalone, .small):
                return onCloseAction != nil
                    ? CGFloat.huiSpaces.primitives.small
                    : CGFloat.huiSpaces.primitives.xSmall
            case (.inline, .large): return CGFloat.huiSpaces.primitives.small
            case (.inline, .medium): return CGFloat.huiSpaces.primitives.small
            case (.inline, .small): return CGFloat.huiSpaces.primitives.small
            }
        }

        private func trailingPadding() -> CGFloat {
            switch (style, size) {
            case (.standalone, .large): return CGFloat.huiSpaces.primitives.small
            case (.standalone, .medium): return CGFloat.huiSpaces.primitives.xSmall
            case (.standalone, .small): return CGFloat.huiSpaces.primitives.xSmall
            case (.inline, .large): return CGFloat.huiSpaces.primitives.small
            case (.inline, .medium): return CGFloat.huiSpaces.primitives.small
            case (.inline, .small): return CGFloat.huiSpaces.primitives.small
            }
        }

        private func verticalPadding() -> CGFloat {
            if style == .standalone && size == .small {
                return CGFloat.huiSpaces.primitives.xxSmall
            } else {
                return CGFloat.huiSpaces.primitives.xSmall
            }
        }

        private func minimumHeight() -> CGFloat {
            switch (style, size) {
            case (.standalone, .large): return 38
            case (.standalone, .medium): return 28
            case (.standalone, .small): return 24
            case (.inline, .large): return 38
            case (.inline, .medium): return 36
            case (.inline, .small): return 33
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .standalone, size: .large, backgroundColor: Color.red) {}
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .standalone, size: .medium, backgroundColor: Color.red) {}
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .standalone, size: .small, backgroundColor: Color.red) {}
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .standalone, size: .large, backgroundColor: Color.red, onCloseAction: nil)
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .standalone, size: .medium, backgroundColor: Color.red, onCloseAction: nil)
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .standalone, size: .small, backgroundColor: Color.red, onCloseAction: nil)
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .inline, size: .large, backgroundColor: Color.red) {}
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .inline, size: .medium, backgroundColor: Color.red) {}
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .inline, size: .small, backgroundColor: Color.red) {}
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .inline, size: .large, backgroundColor: Color.red, onCloseAction: nil)
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .inline, size: .medium, backgroundColor: Color.red, onCloseAction: nil)
        HorizonUI.Tag(title: "Lorem ipsum tag", style: .inline, size: .small, backgroundColor: Color.red, onCloseAction: nil)
    }
}
