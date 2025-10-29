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

/// In a pressed down state adds a narrow vertical line to the left of the button
/// using the button's tint color, and changes the button's background to light gray.
///
/// To indicate selection, use the `.selected(when: Bool)` view modifier on one of the button's parent View.
public struct TintedContextButton: ButtonStyle {
    @Environment(\.isItemSelected) private var isSelected
    private let selectionBackgroundColor: Color = .backgroundLight

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(selectionIndicator(configuration.isPressed || isSelected))
            .animation(.default.speed(2), value: isSelected)
    }

    private func selectionIndicator(_ isSelected: Bool) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .applyTint()
                .frame(width: 3)
            selectionBackgroundColor
        }
        .opacity(isSelected ? 1 : 0)
    }
}

public extension ButtonStyle where Self == TintedContextButton {
    static var tintedContextButton: Self {
        TintedContextButton()
    }
}

// MARK: - Preview

#if DEBUG

#Preview {
    PreviewContainer {
        InstUI.Divider()

        Button { } label: {
            InstUI.LabelCell(label: Text("Button 1"))
                .contentShape(Rectangle())
        }
        .buttonStyle(.tintedContextButton)
        InstUI.Divider()

        Button { } label: {
            InstUI.LabelCell(label: Text("Button 2 - Tint set directly"))
                .contentShape(Rectangle())
        }
        .buttonStyle(.tintedContextButton)
        .tint(.green)
        InstUI.Divider()

        Button { } label: {
            InstUI.LabelCell(label: Text("Button 3 - Always highlighted"))
                .contentShape(Rectangle())
        }
        .buttonStyle(.tintedContextButton)
        .selected(when: true)
        InstUI.Divider()
    }
    .tint(.red)
}

#endif
