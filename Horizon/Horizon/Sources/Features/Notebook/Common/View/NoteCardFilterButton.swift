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

    // MARK: - Dependencies

    let type: CourseNoteLabel
    let selected: Bool

    var body: some View {
        HStack {
            NotebookLabelIcon(type: type)
                .frame(width: 24, height: 24)
            Text(labelFromType(type))
                .font(.regular16)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15.5)
                .fill(Color.white)
                .stroke(colorFromType(type), lineWidth: selected ? 2 : 0)
        )
        .cornerRadius(16)
        .shadow(
            color: Color(red: 66/100,
                         green: 54/100,
                         blue: 36/100)
                .opacity(0.12),
            radius: selected ? 0 : 8
        )
    }
}

// MARK: - Helpers

@inline(__always) func labelFromType(_ type: CourseNoteLabel, isBold: Bool = false) -> String {
    let result = type == .confusing ?
                  String(localized: "Confusing", bundle: .horizon):
                    String(localized: "Important", bundle: .horizon)
    return isBold ? result.uppercased() : result
}
