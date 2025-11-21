//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct NoteCardsView: View {
    // MARK: - Private variables

    @State private var showDeleteConfirmation = false
    @State private var selectedNote: CourseNotebookNote?

    // MARK: - Dependencies

    private let note: CourseNotebookNote
    private let isLoading: Bool
    private let onTapDelete: (CourseNotebookNote) -> Void

    // MARK: - Init

    init(
        note: CourseNotebookNote,
        isLoading: Bool,
        onTapDelete: @escaping (CourseNotebookNote) -> Void
    ) {
        self.note = note
        self.isLoading = isLoading
        self.onTapDelete = onTapDelete
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            NoteCardButton(type: note.type)
            HighlightedText(text: note.highlightedText, type: note.type)
            if let content = note.content, content.isNotEmpty {
                noteView(content)
            }

            HStack(spacing: .zero) {
                noteInfoView
                Spacer()
                deleteButton
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.cardPrimary)
        .clipShape(.rect(cornerRadius: 16))
        .padding([.leading, .bottom], .huiSpaces.space8)
        .padding([.top, .trailing], .huiSpaces.space2)
        .background {
            Rectangle()
                .fill(note.type.backgroundColor)
                .clipShape(.rect(cornerRadius: 16))
        }
        .confirmationDialog("", isPresented: $showDeleteConfirmation, titleVisibility: .hidden) {
            Button(String(localized: "Delete note"), role: .destructive) {
                if let selectedNote {
                    onTapDelete(selectedNote)
                }
            }
            Button(String(localized: "Cancel"), role: .cancel) {
                selectedNote = nil
            }
        }
    }

    private func noteView(_ note: String) -> some View {
        Text(note)
            .frame(maxWidth: .infinity, alignment: .leading)
            .lineLimit(3)
            .huiTypography(.p1)
            .foregroundStyle(Color.huiColors.text.body)
    }

    private var noteInfoView: some View {
        VStack(spacing: .huiSpaces.space4) {
             Text(note.dateFormatted)
                 .huiTypography(.labelSmall)
                 .frame(maxWidth: .infinity, alignment: .leading)
                 .foregroundStyle(Color.huiColors.text.timestamp)

             if let courseName = note.courseName {
                 Text(courseName)
                     .huiTypography(.labelSmall)
                     .frame(maxWidth: .infinity, alignment: .leading)
                     .foregroundStyle(Color.huiColors.text.timestamp)
             }
         }
    }

    private var deleteButton: some View {
        Button {
            selectedNote = note
            showDeleteConfirmation = true
        } label: {
            if isLoading {
                HorizonUI.Spinner(size: .xSmall)
            } else {
                Image.huiIcons.delete
                    .foregroundStyle(Color.huiColors.icon.error)
                    .frame(width: 32, height: 32)
            }
        }
        .disabled(isLoading)
    }
}
#if DEBUG
#Preview {
    NoteCardsView(note: CourseNotebookNote.example, isLoading: false) { _ in }
        .padding()
}
#endif
