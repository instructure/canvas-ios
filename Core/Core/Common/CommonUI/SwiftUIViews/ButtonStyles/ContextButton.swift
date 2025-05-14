//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

/**
 This button style adds a narrow vertical line to the left of the button using the given context color while changing the button's background to light gray in a pressed down state.
 */
public struct ContextButton: ButtonStyle {
    private let selectionBackgroundColor: UIColor = .backgroundLight
    private let contextColor: UIColor
    private let forceHighlight: Bool

    /**
     - parameters:
        - isHighlighted: If this parameter is true, then the button will show its highlighted state even if it isn't pressed down. Useful to indicate selected state.
     */
    public init(contextColor: UIColor?, isHighlighted: Bool = false) {
        self.contextColor = contextColor ?? selectionBackgroundColor
        self.forceHighlight = isHighlighted
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(selectionIndicator(configuration.isPressed || forceHighlight))
    }

    private func selectionIndicator(_ isSelected: Bool) -> some View {
        HStack(spacing: 0) {
            Color(contextColor)
                .frame(width: 3)
            Color(selectionBackgroundColor)
        }
        .opacity(isSelected ? 1 : 0)
    }
}

// MARK: - ViewModifier Friendly methods

public extension ButtonStyle where Self == ContextButton {
    static func contextButton(color: UIColor?, isHighlighted: Bool = false) -> Self {
        ContextButton(contextColor: color, isHighlighted: isHighlighted)
    }
}

// MARK: - Preview

struct ContextButton_Previews: PreviewProvider {
    private static var textButton: some View {
        Button(action: {}) {
            Text(verbatim: "Home Button")
                .padding()
        }
    }
    static var previews: some View {
        textButton.buttonStyle(.contextButton(color: nil))
            .previewLayout(.sizeThatFits)
        textButton.buttonStyle(.contextButton(color: .red))
            .previewLayout(.sizeThatFits)
    }
}
