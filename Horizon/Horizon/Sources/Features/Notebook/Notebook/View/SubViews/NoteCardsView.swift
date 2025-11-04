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

import HorizonUI
import SwiftUI

struct NoteCardsView: View {
    let note: NoteCardModel
    let onTapDelete: (NoteCardModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space16) {
            NoteCardButton(type: note.type)
            HighlightedText(text: note.highlightedText, type: note.type)
            noteView
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
    }

    @ViewBuilder
    private var noteView: some View {
        if let note = note.note {
            Text(note)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(3)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
        }
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
            onTapDelete(note)
        } label: {
            Image.huiIcons.delete
                .foregroundStyle(Color.huiColors.icon.error)
                .frame(width: 32, height: 32)
        }
    }
}

#Preview {
    NoteCardsView(note: NoteCardModel.mockData[0]) { _ in }
        .padding()
}
