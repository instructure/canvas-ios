//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import HorizonUI
import SwiftUI

struct OfflineCheckboxCell: View {
    let state: OfflineCheckboxState
    let label: String
    let action: () -> Void

    var body: some View {
        let isOn = Binding<Bool>(
            get: { state != .unchecked },
            set: { _ in withAnimation(.easeInOut(duration: 0.25)) { action() } }
        )
        HorizonUI.Controls.Checkbox(
            isOn: isOn,
            style: state == .partial ? .partial : .default
        )
        .animation(.easeInOut(duration: 0.25), value: state)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityAddTraits(.isButton)
    }
}
