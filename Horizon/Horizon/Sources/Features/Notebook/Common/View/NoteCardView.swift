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
import HorizonUI

struct NoteCardView: View {
    // MARK: - Properties

    let note: NotebookNote

    var body: some View {
        NotebookCard {
            VStack(alignment: .leading, spacing: .huiSpaces.primitives.xSmall) {
                Text(note.title)
                    .font(.regular12)
                    .padding(.bottom, .huiSpaces.primitives.xSmall)
                Text(note.note)
                    .lineLimit(3)
                    .font(.regular16)
                    .padding(.bottom, .huiSpaces.primitives.xSmall)
                HStack(spacing: .huiSpaces.primitives.xSmall) {
                    ForEach(note.types, id: \.self) { type in
                        noteCardLabelView(type: type)
                    }
                }
            }
        }
    }

    // MARK: - Private

    private func noteCardLabelView(type: CourseNoteLabel) -> some View {
        HStack {
            type.image
            Text(type.label)
                .font(.regular12)
                .foregroundStyle(type.color ?? .huiColors.text.body)
        }
        .padding()
        .frame(height: 31)
        .background(
            RoundedRectangle(cornerRadius: 15.5)
                .stroke(type.color ?? .huiColors.surface.inversePrimary, lineWidth: 2)
        )
        .huiCornerRadius(level: .level3)
    }
}

#Preview {
    VStack {
        NoteCardView(
            note: .init(
                id: "1",
                types: [],
                title: "Title",
                note: "Note"
            )
        )
        NoteCardView(
            note: .init(
                id: "1",
                types: [.important],
                title: "Title",
                note: "Note"
            )
        )
        NoteCardView(
            note: .init(
                id: "2",
                types: [.confusing],
                title: "Title",
                note: "Note"
            )
        )
        NoteCardView(
            note: .init(
                id: "2",
                types: [.important, .confusing],
                title: "Title",
                note: "Note"
            )
        )
    }
}
