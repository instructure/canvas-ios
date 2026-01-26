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

extension InstUI {

    public struct PillButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled
        @ScaledMetric private var uiScale: CGFloat = 1
        private let buttonStyleConfig: InstUI.PillButtonStyle.Config

        public init(_ buttonStyleConfig: InstUI.PillButtonStyle.Config) {
            self.buttonStyleConfig = buttonStyleConfig
        }

        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.regular14)
                .multilineTextAlignment(.center)
                .foregroundStyle(buttonStyleConfig.foregroundColor)
                .padding(.horizontal, 12 * uiScale)
                .padding(.vertical, 4 * uiScale)
                .frame(minHeight: 30 * uiScale.iconScale)
                .background(
                    Capsule()
                        .fill(buttonStyleConfig.backgroundColor)
                        .stroke(
                            buttonStyleConfig.strokeColor,
                            lineWidth: buttonStyleConfig.strokeWidth(uiScale: uiScale)
                        )
                )
                .contentShape(Capsule())
                .opacity(configuration.isPressed || !isEnabled ? 0.7 : 1.0)
        }
    }
}

extension ButtonStyle where Self == InstUI.PillButtonStyle {

    public static func pillButton(_ configuration: InstUI.PillButtonStyle.Config) -> Self {
        InstUI.PillButtonStyle(configuration)
    }

    public static var pillButtonBrandFilled: Self {
        pillButton(.brandFilled)
    }

    public static var pillButtonDefaultOutlined: Self {
        pillButton(.defaultOutlined)
    }

    public static func pillButtonFilled(color: Color) -> Self {
        pillButton(.filled(color: color))
    }

    public static func pillButtonOutlined(color: Color) -> Self {
        pillButton(.outlined(color: color))
    }

    public static func pillButtonOutlined(textColor: Color, borderColor: Color) -> Self {
        pillButton(.outlined(textColor: textColor, borderColor: borderColor))
    }
}

#if DEBUG

#Preview {
    PillButtonStorybook()
}

#endif
