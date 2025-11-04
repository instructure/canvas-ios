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

struct NoteCardListView: View {
    let notes: [NoteCardModel] = NoteCardModel.mockData
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: .huiSpaces.space16) {
                HStack {
                    listCourses
                    listCourses
                }
                dateView
            }
            .padding(.huiSpaces.space16)
        }
    }

    private var dateView: some View {
        ForEach(notes) { note in
            NoteCardsView(note: note) { deletedNote in
                print(deletedNote)
            }
        }
    }

    private var listCourses: some View {
        HorizonUI.FilterChip(
            style: .menu(
                .grayOutline(
                    selectedItem: nil,
                    items: dropdownMenuItemMock,
                    headerAlignment: .center,
                    showCheckmark: false,
                    placeHolder: "Please select"
                )
            )
        )
    }

    private let dropdownMenuItemMock: [HorizonUI.DropdownMenuItem] = [
        .init(id: "1", name: "Option 1"),
        .init(id: "2", name: "Option 2"),
        .init(id: "3", name: "Option 3"),
        .init(id: "4", name: "Option 4")
    ]
}

#Preview {
    NoteCardListView()
}
