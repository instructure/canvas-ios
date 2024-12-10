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

struct ButtonColors {
    static let dark = Color(red: 39/255, green: 53/255, blue: 64/255)
    static let white = Color.white
    static let ai = Gradient(
        colors: [
            Color(red: 9/255, green: 80/255, blue: 140/255),
            Color(red: 2/255, green: 103/255, blue: 45/255)
        ]
    )
    static let blue = Color(red: 43/255, green: 122/255, blue: 188/255)
    static let beige = Color(red: 251/255, green: 245/255, blue: 237/255)
}

enum HorizonButtonWidth {
    case infinity
    case none
}

struct HorizonButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    private let isSmall: Bool
    private let background: AnyShapeStyle
    private let foreground: Color
    private let leading: AnyView
    private let width: HorizonButtonWidth
    private let trailing: AnyView
}

extension HorizonButtonStyle {
    init(
        background: some ShapeStyle,
        foreground: Color,
        isSmall: Bool = false,
        leading: some View = EmptyView(),
        width: HorizonButtonWidth = .infinity,
        trailing: some View = EmptyView()
    ) {
        self.background = AnyShapeStyle(background)
        self.foreground = foreground
        self.isSmall = isSmall
        self.leading = AnyView(leading)
        self.width = width
        self.trailing = AnyView(trailing)
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            self.leading
            configuration.label
            self.trailing
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: width == .infinity ? .infinity : .none)
        .frame(height: isSmall ? 40 : 44)
        .background(background)
        .foregroundStyle(foreground)
        .cornerRadius(isSmall ? 20 : 22)
        .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
    }
}
