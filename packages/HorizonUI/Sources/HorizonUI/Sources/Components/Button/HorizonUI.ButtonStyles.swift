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
        private let variant: Variant
        private let isSmall: Bool
        private let fillsWidth: Bool
        private let leading: AnyView
        private let trailing: AnyView

        init(
            variant: Variant,
            isSmall: Bool = false,
            fillsWidth: Bool = false,
            leading: some View = EmptyView(),
            trailing: some View = EmptyView()
        ) {
            self.variant = variant
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
            .padding(.horizontal, 16)
            .frame(height: isSmall ? 40 : 44)
            .setFrameMaxWidth(isInfinite: fillsWidth)
            .background(AnyShapeStyle(variant.background))
            .foregroundStyle(variant.foregroundColor)
            .cornerRadius(isSmall ? 20 : 22)
            .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1.0) : 0.5)
        }
    }
}

private extension View {
    func setFrameMaxWidth(isInfinite: Bool) -> some View {
        modifier(ConditionalFrameMaxWidthModifier(isInfinite: isInfinite))
    }
}

private struct ConditionalFrameMaxWidthModifier: ViewModifier {
    let isInfinite: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isInfinite {
            content.frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}
