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
        VStack {
            type.image(selected: selected)
                .frame(width: .huiSpaces.space24, height: .huiSpaces.space24)
            Text(type.label)
                .huiTypography(.buttonTextLarge)
        }
        .frame(height: 102)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level2.attributes.radius)
                .fill(Color.huiColors.surface.cardPrimary)
                .stroke(selected ? type.color : HorizonUI.colors.lineAndBorders.containerStroke, lineWidth: 1)
        )
        .cornerRadius(16)
    }
}

#Preview {
    HStack(spacing: 16) {
        NoteCardFilterButton(type: .confusing, selected: true)
        NoteCardFilterButton(type: .important, selected: false)
    }
}
