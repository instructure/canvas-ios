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
import SwiftUI
import SwiftUICore

struct NotebookView: View {

    @Bindable var viewModel: NotebookViewModel

    @Environment(\.viewController) var viewController

    init(viewModel: NotebookViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NotesBody(title: "Notebook", router: viewModel.router) {
            NotebookSearchBar(onSearch: viewModel.onSearch).padding(.vertical, 24)
            ListViewItems(listItems: $viewModel.listItems, onTap: viewModel.onTap, viewController: viewController)
        }
    }

    struct ListViewItems: View {

        @Binding var listItems: [NotebookListItem]

        let onTap: ((NotebookListItem, WeakViewController) -> Void)

        let viewController: WeakViewController

        var body: some View {
            VStack(spacing: 16) {
                ForEach(listItems, id: \.id) { listItem in
                    ListViewItem(onTap: onTap, item: listItem, viewController: viewController)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct ListViewItem: View {
        let onTap: ((NotebookListItem, WeakViewController) -> Void)

        let item: NotebookListItem

        let viewController: WeakViewController

        var body: some View {
            NotebookCard {
                Text(item.institution).font(.regular12).multilineTextAlignment(.leading)
                Text(item.course).font(.regular22).multilineTextAlignment(.leading)
            }
            .onTapGesture { onTap(item, viewController) }
        }
    }
}

#if DEBUG
    struct NotebookView_Previews: PreviewProvider {
        static var previews: some View {
            NotebookView(
                viewModel: .init(
                    router: AppEnvironment.shared.router,
                    getCoursesUseCase: GetCoursesUseCase()
                )
            )
        }
    }
#endif
