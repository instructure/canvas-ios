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
        private let leading: AnyView
        private let trailing: AnyView

        fileprivate init(
            background: any ShapeStyle,
            foreground: Color,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: some View = EmptyView(),
            trailing: some View = EmptyView()
        ) {
            self.background = AnyShapeStyle(background)
            self.foreground = foreground
            self.isSmall = isSmall
            self.fillsWidth = fillsWidth
            self.leading = AnyView(leading)
            self.trailing = AnyView(trailing)
        }

        func makeBody(configuration: Configuration) -> some View {
            HStack {
                self.leading.frame(alignment: .center)
                configuration.label
                self.trailing.frame(alignment: .center)
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
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonUI.ButtonStyles {
        self.init(
            background: LinearGradient(
                gradient: Gradient(colors: [ButtonColors.AI.gradientTop, ButtonColors.AI.gradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            ),
            foreground: ButtonColors.white,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func beige(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonUI.ButtonStyles {
        self.init(
            background: ButtonColors.beige,
            foreground: ButtonColors.darkText,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func black(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonUI.ButtonStyles {
        .init(
            background: Color.black,
            foreground: ButtonColors.white,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func blue(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonUI.ButtonStyles {
        .init(
            background: ButtonColors.blue,
            foreground: ButtonColors.white,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }

    static func white(
        isSmall: Bool = false,
        fillsWidth: Bool = false,
        leading: some View = EmptyView(),
        trailing: some View = EmptyView()
    ) -> HorizonUI.ButtonStyles {
        .init(
            background: Color.white,
            foreground: ButtonColors.darkText,
            fillsWidth: fillsWidth,
            leading: leading,
            trailing: trailing
        )
    }
}


fileprivate struct ButtonColors {
    static let darkText = Color(red: 39/255, green: 53/255, blue: 64/255)
    static let white = Color.white

    struct AI {
        static let gradientTop = Color(red: 9/255, green: 80/255, blue: 140/255)
        static let gradientBottom = Color(red: 2/255, green: 103/255, blue: 45/255)
    }

    static let blue = Color(red: 43/255, green: 122/255, blue: 188/255)
    static let beige = Color(red: 251/255, green: 245/255, blue: 237/255)
}
