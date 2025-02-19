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

/// The intention is to call this in the same was as .popover
/// e.g., Button("Pop!").tooltip($isPresented)
extension View {
    func huiTooltip(
        isPresented: Binding<Bool>,
        arrowEdge: Edge? = nil,
        style: HorizonUI.Tooltip.Style = .primary,
        content: @escaping () -> some View
    ) -> some View {
        modifier(
            HorizonUI.Tooltip(
                isPresented: isPresented,
                arrowEdge: arrowEdge,
                style: style,
                content: content
            ))
    }
}

extension HorizonUI {
    struct Tooltip: ViewModifier {
        // MARK: - Dependencies

        private let arrowEdge: Edge?
        private let content: AnyView
        private let style: HorizonUI.Tooltip.Style
        private var isPresented: Binding<Bool>

        // MARK: - init

        init(
            isPresented: Binding<Bool>,
            arrowEdge: Edge? = nil,
            style: HorizonUI.Tooltip.Style = .primary,
            @ViewBuilder content: @escaping () -> any View
        ) {
            self.arrowEdge = arrowEdge
            self.style = style
            self.content = AnyView(content())
            self.isPresented = isPresented
        }

        func body(content: Content) -> some View {
            content
                .popover(
                    isPresented: isPresented,
                    arrowEdge: arrowEdge
                ) {
                    self.content
                        .padding([.horizontal], .huiSpaces.space16)
                        .foregroundStyle(style.foregroundColor)
                        .presentationCompactAdaptation(.popover)
                        .presentationBackground(style.backgroundColor)
                }
        }

        enum Style: String, CaseIterable {
            case primary = "Primary"
            case secondary = "Secondary"

            var foregroundColor: Color {
                switch self {
                case .primary:
                    Color.huiColors.text.surfaceColored
                case .secondary:
                    Color.huiColors.text.body
                }
            }

            var backgroundColor: Color {
                switch self {
                case .primary:
                    return Color.huiColors.surface.inverseSecondary
                case .secondary:
                    return Color.huiColors.surface.cardPrimary
                }
            }
        }
    }
}
