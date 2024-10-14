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

public enum ContextButtonState {
    case normal
    case selected
    case highlighted
}

/**
 This button style adds a narrow vertical line to the left of the button using the given context color while changing the button's background to light gray in a pressed down state.
 */
public struct ContextButton: ButtonStyle {
    private let selectionBackgroundColor: UIColor = .backgroundLight
    private let contextColor: UIColor
    private let state: ContextButtonState

    /**
     - parameters:
        - state: If this parameter is set to `.highlighted` or `.selected`, then the button will show its highlighted state even if it isn't pressed down. With `.highlighted` state not showing the vertical line on the left. default is `.normal`.
     */
    public init(contextColor: UIColor?, state: ContextButtonState) {
        self.contextColor = contextColor?.ensureContrast(against: .backgroundLightest) ?? selectionBackgroundColor
        self.state = state
    }

    public init(contextColor: UIColor?) {
        self.contextColor = contextColor?.ensureContrast(against: .backgroundLightest) ?? selectionBackgroundColor
        self.state = .normal
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.background(selectionIndicator(given: configuration))
    }

    private func selectionIndicator(given configuration: Configuration) -> some View {
        let visible = configuration.isPressed || state != .normal
        return HStack(spacing: 0) {
            if configuration.isPressed || state == .selected {
                Color(contextColor)
                    .frame(width: 3)
            }
            Color(selectionBackgroundColor)
        }
        .opacity(visible ? 1 : 0)
    }
}

// MARK: - ViewModifier Friendly methods

public extension ButtonStyle where Self == ContextButton {

    static func contextButton(color: UIColor?) -> Self {
        ContextButton(contextColor: color)
    }

    static func contextButton(color: UIColor?, isSelected: Bool) -> Self {
        ContextButton(contextColor: color, state: isSelected ? .selected : .normal)
    }

    static func contextButton(color: UIColor?, state: ContextButtonState) -> Self {
        ContextButton(contextColor: color, state: state)
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
