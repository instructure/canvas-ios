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

struct NoteCardLabelView: View {
    // MARK: - Properties
    let type: CourseNoteLabel

    var body: some View {
        HStack {
            NotebookLabelIcon(type: type)
            Text(type.label)
                .font(.regular12)
                .foregroundStyle(type.color)
        }
        .padding()
        .frame(height: 31)
        .background(
            RoundedRectangle(cornerRadius: 15.5)
                .stroke(type.color, lineWidth: 2)
        )
        .cornerRadius(15.5)
    }
}
