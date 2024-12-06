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

struct NoteCardView: View {
    // MARK: - Properties

    let note: NotebookNote

    var body: some View {
        NotebookCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.title)
                    .font(.regular12)
                    .padding(.bottom, 8)
                Text(note.note)
                    .font(.regular16)
                    .padding(.bottom, 8)
                if let type = note.type {
                    NoteCardLabelView(type: type)
                }
            }
        }
    }
}

#Preview {
    VStack {
        NoteCardView(
            note: .init(
                id: "1",
                type: .important,
                title: "Title",
                note: "Note"
            )
        )
        NoteCardView(
            note: .init(
                id: "2",
                type: .confusing,
                title: "Title",
                note: "Note"
            )
        )
    }
}
