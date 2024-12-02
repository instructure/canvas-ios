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

import SwiftUICore
import SwiftUI

struct NoteCard: View {
    let note: NotebookNote

    var body: some View {
        NotebookCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.title).font(.regular12).padding(.bottom, 8)
                Text(note.note).font(.regular16).padding(.bottom, 8)
                if let type = note.type {
                    NoteCardLabel(type: type)
                }
            }
        }
    }
}

struct NoteCardLabel: View {
    let type: NotebookNoteLabel

    var body: some View {
        HStack {
            NotebookLabelIcon(type: type)
            Text(labelFromType(type)).font(.regular12).foregroundStyle(colorFromType(type))
        }
        .frame(height: 31)
        .border(colorFromType(type), width: 1)
        .cornerRadius(15.5)
    }
}

struct FilterButton: View {
    let type: NotebookNoteLabel

    var body: some View {
        HStack {
            NotebookLabelIcon(type: type).frame(width: 24, height: 24)
            Text(labelFromType(type)).font(.regular16)
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 1, y: 2)
    }
}

struct NotebookLabelIcon: View {
    let type: NotebookNoteLabel

    var body: some View {
        if(type == .confusing) {
            ConfusingIcon()
        } else {
            ImportantIcon()
        }
    }
}

struct ConfusingIcon: View {
    var body: some View {
        Image(systemName: "questionmark.circle").foregroundStyle(colorFromType(.confusing))
    }
}

struct ImportantIcon: View {
    var body: some View {
        Image("Flag", bundle: .main).renderingMode(.template).foregroundStyle(colorFromType(.important))
    }
}

// MARK: - Helpers

@inline(__always) func colorFromType(_ type: NotebookNoteLabel) -> Color {
    type == .confusing ? Color(red: 0.682, green: 0.106, blue: 0.122) : Color(red: 0.055, green: 0.408, blue: 0.702)
}

@inline(__always) func labelFromType(_ type: NotebookNoteLabel, isBold: Bool = false) -> String {
    let result = (type == .confusing ? "Confusing": "Important")
    return isBold ? result.uppercased() : result
}

#if DEBUG
struct NoteCard_Previews: PreviewProvider {
    static var previews: some View {
        return VStack {
            FilterButton(type: .important)
            FilterButton(type: .confusing)
            NoteCard(
                note: .init(
                    id: "1",
                    type: .important,
                    title: "Title",
                    note: "Note"
                )
            )
            NoteCard(
                note: .init(
                    id: "2",
                    type: .confusing,
                    title: "Title",
                    note: "Note"
                )
            )
        }
    }
}
#endif
