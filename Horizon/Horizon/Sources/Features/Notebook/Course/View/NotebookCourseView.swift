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
import Core

struct NotebookCourseView: View {

    @Bindable var viewModel: NotebookCourseViewModel

    @Environment(\.viewController) private var viewController

    var body: some View {
        return NotesBody(
            title: viewModel.title,
            router: viewModel.router
        ) {
            NotebookSearchBar(term: $viewModel.term).padding(.top, 32)

            Text(String(localized: "Filter", bundle: .horizon)).font(.regular16)
                .padding(.top, 32)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                FilterButton(.confusing, enabled: viewModel.isConfusingEnabled).onTapGesture {
                    viewModel.filter = .confusing
                }
                FilterButton(.important, enabled: viewModel.isImportantEnabled).onTapGesture {
                    viewModel.filter = .important
                }
            }.frame(maxWidth: .infinity)

            Text("Notes").font(.regular16)
                .padding(.top, 32)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.notes) { note in
                NoteCardView(note).onTapGesture {
                    viewModel.onNoteTapped(note, viewController: viewController)
                }
            }
        }
    }
}
