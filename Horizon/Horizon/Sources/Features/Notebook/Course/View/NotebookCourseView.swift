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
import Core

struct NotebookCourseView: View {

    @Bindable var viewModel: NotebookCourseViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        NotesBody(
            title: viewModel.title,
            leading: {
                NotesIconButton(systemName: "arrow.left") {
                    viewModel.onBack(viewController: viewController)
                }
            },
            trailing: { }
        ) {
            NotebookSearchBar(term: $viewModel.term).padding(.top, 32)

            Text("Filter", bundle: .horizon).font(.regular16)
                .padding(.top, 32)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                NoteCardFilterButton(type: .confusing, selected: viewModel.isConfusingEnabled)
                    .onTapGesture {
                        viewModel.filter = .confusing
                    }
                NoteCardFilterButton(type: .important, selected: viewModel.isImportantEnabled)
                    .onTapGesture {
                        viewModel.filter = .important
                    }
            }.frame(maxWidth: .infinity)

            Text("Notes", bundle: .horizon).font(.regular16)
                .padding(.top, 32)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.notes) { note in
                NoteCardView(note: note)
                    .onTapGesture {
                        viewModel.onNoteTapped(note, viewController: viewController)
                    }
            }
        }
    }
}