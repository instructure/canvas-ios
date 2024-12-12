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

extension HorizonUI {
    struct ButtonStyles: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled
        private let background: AnyShapeStyle
        private let foreground: Color
        private let isSmall: Bool
        private let fillsWidth: Bool
        private let leading: HorizonUI.Icon?
        private let trailing: HorizonUI.Icon?

        fileprivate init(
            background: any ShapeStyle,
            foreground: Color,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: HorizonUI.Icon? = nil,
            trailing: HorizonUI.Icon? = nil
        ) {
            self.background = AnyShapeStyle(background)
            self.foreground = foreground
            self.isSmall = isSmall
            self.fillsWidth = fillsWidth
            self.leading = leading
            self.trailing = trailing
        }

        func makeBody(configuration: Configuration) -> some View {
            HStack {
                leading?
                    .renderingMode(.template)
                    .foregroundColor(Color.white)

                configuration.label

                trailing?
                    .renderingMode(.template)
                    .foregroundColor(Color.white)
            }
            .huiTypography(.buttonTextLarge)
            .tracking(100)
            .padding(.horizontal, 16)
            .frame(height: isSmall ? 40 : 44)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .background(background)
            .foregroundStyle(foreground)
            .cornerRadius(isSmall ? 20 : 22)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
        }
    }
}

extension HorizonUI.ButtonStyles {
    static func ai(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: HorizonUI.Icon? = nil,
        trailing: HorizonUI.Icon? = nil
    ) -> HorizonUI.ButtonStyles {
        self.init(
            background: LinearGradient(
                gradient: Gradient(colors: [
                    Color.huiColors.surface.aiGradientStart,
                    Color.huiColors.surface.aiGradientEnd
                ]),
                startPoint: .top,
                endPoint: .bottom
            ),
            foreground: Color.huiColors.text.surfaceColored,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func beige(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: HorizonUI.Icon? = nil,
        trailing: HorizonUI.Icon? = nil
    ) -> HorizonUI.ButtonStyles {
        self.init(
            background: Color.huiColors.surface.pagePrimary,
            foreground: Color.huiColors.text.title,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func black(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: HorizonUI.Icon? = nil,
        trailing: HorizonUI.Icon? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            background: Color.huiColors.surface.inversePrimary,
            foreground: Color.huiColors.text.surfaceColored,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func blue(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: HorizonUI.Icon? = nil,
        trailing: HorizonUI.Icon? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            background: Color.huiColors.surface.institution,
            foreground: Color.huiColors.text.surfaceColored,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func white(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: HorizonUI.Icon? = nil,
        trailing: HorizonUI.Icon? = nil
    ) -> HorizonUI.ButtonStyles {
        .init(
            background: Color.huiColors.surface.pageSecondary,
            foreground: Color.huiColors.text.title,
            isSmall: isSmall,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }
}

extension HorizonUI.Colors.Surface {
    var aiGradientStart: Color { Color(hexString: "#09508C") }
    var aiGradientEnd: Color { Color(hexString: "#02672D") }
}
