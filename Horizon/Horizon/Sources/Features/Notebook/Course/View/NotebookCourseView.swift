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

    init(_ viewModel: NotebookCourseViewModel = NotebookCourseViewModel(courseID: "")) {
        self.viewModel = viewModel
    }

    var body: some View {
        return NotesBody(
            title: viewModel.title,
            router: viewModel.router
        ) {
            NotebookSearchBar() { _ in }.padding(.bottom, 32).padding(.top, 32)
            NotebookCard {
                Text("Monday, 12/12/2024").font(.regular12).padding(.bottom, 8)
                Text("This is a note").font(.regular16)
            }
        }
    }
}

#if DEBUG
    struct NotebookCourseView_Previews: PreviewProvider {
        static var previews: some View {
            NotebookCourseView()
        }
    }
#endif
