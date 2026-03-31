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

// MARK: - ButtonStyle members

extension ButtonStyle where Self == InstUI.PillButtonStyle {

    public static var pillTintFilled: Self {
        InstUI.PillButtonStyle(.tintFilled)
    }

    public static var pillTintOutlined: Self {
        InstUI.PillButtonStyle(.tintOutlined)
    }

    public static var pillDefaultOutlined: Self {
        InstUI.PillButtonStyle(.defaultOutlined)
    }

    public static func pillCustomOutlined(textColor: Color, borderColor: Color) -> Self {
        InstUI.PillButtonStyle(.customOutlined(textColor: textColor, borderColor: borderColor))
    }
}

// MARK: - PillButtonStyle struct

extension InstUI {

    public struct PillButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) private var isEnabled

        private let buttonStyleConfig: InstUI.PillButtonStyle.Config

        public init(_ buttonStyleConfig: InstUI.PillButtonStyle.Config) {
            self.buttonStyleConfig = buttonStyleConfig
        }

        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .customTint(buttonStyleConfig.foregroundColor)
                .background(
                    BackgroundView(
                        isFilled: buttonStyleConfig.isFilled,
                        isPressed: configuration.isPressed,
                        borderColor: buttonStyleConfig.borderColor.colorOrTint,
                    )
                )
                .contentShape(Capsule())
                .opacity(buttonOpacity(isFilled: buttonStyleConfig.isFilled, isPressed: configuration.isPressed))
        }

        private func buttonOpacity(isFilled: Bool, isPressed: Bool) -> Double {
            if isFilled {
                isPressed || !isEnabled ? 0.7 : 1.0
            } else {
                isEnabled ? 1.0 : 0.7
            }
        }
    }

    private struct BackgroundView: View {
        @Environment(\.colorScheme) private var colorScheme
        @ScaledMetric private var uiScale: CGFloat = 1

        let isFilled: Bool
        let isPressed: Bool
        let borderColor: AnyShapeStyle

        var body: some View {
            Capsule()
                .fill(fillStyle)
                .strokeBorder(borderColor, lineWidth: isFilled ? 0 : uiScale)
        }

        private var fillStyle: some ShapeStyle {
            if isFilled {
                AnyShapeStyle(.tint)
            } else {
                if isPressed {
                    // In dark mode we need stronger colors to be as prominent as in light mode
                    AnyShapeStyle(borderColor.opacity(colorScheme == .dark ? 0.3 : 0.1))
                } else {
                    AnyShapeStyle(.clear)
                }
            }
        }
    }
}

private extension Color? {
    var colorOrTint: AnyShapeStyle {
        self.map(AnyShapeStyle.init) ?? AnyShapeStyle(.tint)
    }
}

#if DEBUG

#Preview {
    PillButtonStorybook()
}

#endif
