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

struct NotebookCourseListView: View {
    @Bindable var viewModel: NotebookCourseListViewModel
    @Environment(\.viewController) var viewController

    init(viewModel: NotebookCourseListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NotesBody(
            title: String(localized: "Notebook", bundle: .horizon),
            leading: {
                HorizonUI.IconButton(.huiIcons.arrowBack, type: .white) {
                    viewModel.onBack(viewController: viewController)
                }
            },
            trailing: {}
        ) {
            NotebookSearchBar(term: $viewModel.term)
                .padding(.vertical, .huiSpaces.primitives.medium)
            NoteableTextView(
                "This text belongs to a course. When highlighted, a note will be associated with the course. The highlight key is used to uniquely identify a block of text.",
                highlightsKey: "highlightKey1",
                courseId: "531",
                moduleId: "1",
                moduleType: .subHeader
            )
            ListViewItems(listItems: viewModel.listItems,
                          onTap: viewModel.onTap,
                          viewController: viewController)
        }
    }

    struct ListViewItems: View {
        var listItems: [NotebookListItem]
        let onTap: (NotebookListItem, WeakViewController) -> Void
        let viewController: WeakViewController

        var body: some View {
            VStack(spacing: .huiSpaces.primitives.smallMedium) {
                ForEach(listItems, id: \.id) { listItem in
                    ListViewItem(onTap: onTap, item: listItem, viewController: viewController)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct ListViewItem: View {
        let onTap: (NotebookListItem, WeakViewController) -> Void
        let item: NotebookListItem
        let viewController: WeakViewController

        var body: some View {
            NotebookCard {
                Text(item.institution)
                    .font(.regular12)
                    .multilineTextAlignment(.leading)
                Text(item.course)
                    .font(.regular22)
                    .multilineTextAlignment(.leading)
            }
            .onTapGesture { onTap(item, viewController) }
        }
    }
}

#Preview {
    NotebookCourseListView(
        viewModel: .init()
    )
}
