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

    @State private var viewModel: NotebookCourseViewModel

    @Environment(\.viewController) private var viewController

    init(_ viewModel: NotebookCourseViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        return NotesBody(
            title: viewModel.title,
            router: viewModel.router
        ) {
            NotebookSearchBar(onSearch: viewModel.onSearch).padding(.top, 32)

            Text("Filter").font(.regular16)
                .padding(.top, 32)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 8) {
                FilterButton(.confusing, enabled: viewModel.isConfusingEnabled).onTapGesture {
                    viewModel.onFilter(.confusing)
                }
                FilterButton(.important, enabled: viewModel.isImportantEnabled).onTapGesture {
                    viewModel.onFilter(.important)
                }
            }.frame(maxWidth: .infinity)

            Text("Notes").font(.regular16)
                .padding(.top, 32)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(viewModel.notes) { note in
                NoteCard(note).onTapGesture {
                    viewModel.onNoteTapped(note, viewController: viewController)
                }
            }
        }
    }
}

#if DEBUG
    struct NotebookCourseView_Previews: PreviewProvider {
        static var previews: some View {
            NotebookCourseView(
                .init(courseID: "1", getCourseNotesInteractor: GetCourseNotesInteractor(courseNotesRepository: CourseNotesRepository()))
            )
        }
    }
#endif
