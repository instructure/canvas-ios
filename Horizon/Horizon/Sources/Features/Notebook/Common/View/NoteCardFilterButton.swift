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

import HorizonUI
import SwiftUI

struct NoteCardFilterButton: View {

    // MARK: - Dependencies

    let type: CourseNoteLabel
    let selected: Bool

    var body: some View {
        HStack {
            type.image
                .frame(width: 24, height: 24)
            Text(type.label)
                .font(.regular16)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15.5)
                .fill(Color.white)
                .stroke(type.color ?? .huiColors.surface.inversePrimary, lineWidth: selected ? 2 : 0)
        )
        .cornerRadius(16)
        .huiElevation(level: selected ? .level0 : .level4)
    }
}
