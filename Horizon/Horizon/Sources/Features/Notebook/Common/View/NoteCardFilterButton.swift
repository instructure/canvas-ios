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

struct NoteCardFilterButton: View {
    // MARK: - Properties

    let textEnabledColor = Color(red: 39/255, green: 53/255, blue: 64/255)
    let backgroundEnabledColor = Color.white
    let backgroundDisabledColor = Color(red: 94/100, green: 95/100, blue: 96/100)

    // MARK: - Dependencies

    let type: NotebookNoteLabel
    let enabled: Bool

    var body: some View {
        HStack {
            NotebookLabelIcon(type: type, enabled: enabled)
                .frame(width: 24, height: 24)
            Text(labelFromType(type))
                .font(.regular16)
                .foregroundColor(enabled ? textEnabledColor : Color.disabledGray
            )
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(enabled ? backgroundEnabledColor : backgroundDisabledColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: enabled ? 8 : 0)
    }
}

// MARK: - Helpers

@inline(__always) func labelFromType(_ type: NotebookNoteLabel, isBold: Bool = false) -> String {
    let result = type == .confusing ?
                  String(localized: "Confusing", bundle: .horizon):
                    String(localized: "Important", bundle: .horizon)
    return isBold ? result.uppercased() : result
}
