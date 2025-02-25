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
            VStack(alignment: .leading, spacing: .huiSpaces.space8) {
                Text(note.title)
                    .font(.regular12)
                    .padding(.bottom, .huiSpaces.space8)
                if !note.highlightedText.isEmpty {
                    Text(note.highlightedText)
                        .font(.regular14Italic)
                        .padding(.bottom, .huiSpaces.space8)
                }
                if !note.note.isEmpty {
                    Text(note.note)
                        .lineLimit(3)
                        .font(.regular16)
                        .padding(.bottom, .huiSpaces.space8)
                }
                HStack(spacing: .huiSpaces.space8) {
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
                highlightedText: "This is some highlighted text",
                note: "Note",
                title: "Title",
                types: [],
                cursor: "1"
            )
        )
        NoteCardView(
            note: .init(
                id: "1",
                highlightedText: "This is some highlighted text again",
                note: "Note",
                title: "Title",
                types: [.important],
                cursor: "2"
            )
        )
        NoteCardView(
            note: .init(
                id: "2",
                highlightedText: "This is some highlighted text again again",
                note: "Note",
                title: "Title",
                types: [.confusing],
                cursor: "3"
            )
        )
        NoteCardView(
            note: .init(
                id: "2",
                highlightedText: "This is some highlighted text again again again",
                note: "Note",
                title: "Title",
                types: [.important, .confusing],
                cursor: "4"
            )
        )
    }
}
