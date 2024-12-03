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

private let textDisabledColor = Color(red: 27/100, green: 36/100, blue: 45/100)

struct NoteCardView: View {
    // MARK: - Properties

    let note: NotebookNote

    // MARK: - Init

    init(_ note: NotebookNote) {
        self.note = note
    }

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

struct NoteCardLabelView: View {
    // MARK: - Properties
    let type: NotebookNoteLabel

    var body: some View {
        HStack {
            NotebookLabelIcon(type)
            Text(labelFromType(type)).font(.regular12).foregroundStyle(colorFromType(type))
        }
        .padding()
        .frame(height: 31)
        .background(
            RoundedRectangle(cornerRadius: 15.5)
                .stroke(colorFromType(type), lineWidth: 2)
        )
        .cornerRadius(15.5)
    }
}

struct FilterButton: View {
    // MARK: - Properties

    let type: NotebookNoteLabel
    let enabled: Bool
    let textEnabledColor = Color(red: 39/255,
                                 green: 53/255,
                                 blue: 64/255)
    let backgroundEnabledColor = Color.white
    let backgroundDisabledColor = Color(red: 94/100,
                                        green: 95/100,
                                        blue: 96/100)

    // MARK: - Init

    init(_ type: NotebookNoteLabel, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
    }

    var body: some View {
        HStack {
            NotebookLabelIcon(type, enabled: enabled)
                .frame(width: 24, height: 24)
            Text(labelFromType(type))
                .font(.regular16)
                .foregroundColor(enabled ? textEnabledColor : textDisabledColor
            )
        }
        .frame(height: 48)
        .frame(maxWidth: .infinity)
        .background( enabled ? backgroundEnabledColor : backgroundDisabledColor )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2),
                radius: enabled ? 8 : 0, x: 0, y: 0)
    }
}

struct NotebookLabelIcon: View {
    // MARK: - Properties

    let type: NotebookNoteLabel
    let enabled: Bool

    // MARK: - Init

    init(_ type: NotebookNoteLabel, enabled: Bool = true) {
        self.type = type
        self.enabled = enabled
    }

    var body: some View {
        let image = type == .confusing ?
            Image(systemName: "questionmark.circle") :
            Image("Flag", bundle: .main).renderingMode(.template)
        return image.foregroundStyle(
            enabled ? colorFromType(type) : textDisabledColor
        )
    }
}

// MARK: - Helpers

@inline(__always) func colorFromType(_ type: NotebookNoteLabel) -> Color {
    type == .confusing ?
        Color(red: 0.682,
              green: 0.106,
              blue: 0.122) :
        Color(red: 0.055,
        green: 0.408,
        blue: 0.702)
}

@inline(__always) func labelFromType(_ type: NotebookNoteLabel, isBold: Bool = false) -> String {
    let result = type == .confusing ?
                  String(localized: "Confusing", bundle: .horizon):
                    String(localized: "Important", bundle: .horizon)
    return isBold ? result.uppercased() : result
}

#if DEBUG
struct NoteCard_Previews: PreviewProvider {
    static var previews: some View {
        return VStack {
            FilterButton(.important)
            FilterButton(.confusing, enabled: false)
            NoteCardView(
                .init(
                    id: "1",
                    type: .important,
                    title: "Title",
                    note: "Note"
                )
            )
            NoteCardView(
                .init(
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
