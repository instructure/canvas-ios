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

import Core
import HorizonUI
import SwiftUI

struct NoteCardView: View {

    // MARK: - Dependencies

    let note: NotebookNote
    let onEdit: (() -> Void)?

    // MARK: - Init

    init(note: NotebookNote, onEdit: (() -> Void)? = nil) {
        self.note = note
        self.onEdit = onEdit
    }

    var body: some View {
        NotebookCard {
            VStack(alignment: .leading, spacing: .huiSpaces.space16) {
                HStack(alignment: .center) {
                    Text(note.title).font(.regular12)
                    Spacer()
                    if let onEdit = onEdit {
                        HorizonUI.icons.editNote
                            .onTapGesture {
                                onEdit()
                            }
                    }
                }
                if !note.highlightedText.isEmpty {
                    HighlightedText(note.highlightedText, ofTypes: note.types)
                }
                if !note.note.isEmpty {
                    Text(note.note)
                        .huiTypography(.p1)
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
            type.image()
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
        .huiCornerRadius(level: .level3)
    }
}

#if DEBUG
#Preview {
    VStack {
        NoteCardView(
            note: NotebookNote(
                courseNotebookNote: CourseNotebookNote.example.copy(content: "")
            )
        )

        NoteCardView(
            note: NotebookNote(
                courseNotebookNote: CourseNotebookNote.example
            )
        )
    }
}
#endif
