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

extension View {
    /// Adds a "Done" button above the currently focused input's keyboard. Tapping the button will defocus the input.
    public func keyboardToolbarDoneButton(_ isFocused: FocusState<Bool>.Binding) -> some View {
        modifier(KeyboardToolbarDoneButtonViewModifier(isFocused: isFocused))
    }
}

private struct KeyboardToolbarDoneButtonViewModifier: ViewModifier {
    @FocusState.Binding private var isFocused: Bool

    init(isFocused: FocusState<Bool>.Binding) {
        self._isFocused = isFocused
    }

    // FIXME: This will properly show one Done button on the first page of SpeedGrader,
    //  but shows no keyboard toolbar at all for the next page.
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    // Only add the button for the currently active keyboard,
                    // otherwise all keyboards with this modifier will get each other's buttons.
                    if isFocused {
                        Spacer()
                        Button(String(localized: "Done", bundle: .core)) {
                            isFocused = false
                        }
                        .font(.regular16, lineHeight: .fit)
                    }
                }
            }
    }
}
