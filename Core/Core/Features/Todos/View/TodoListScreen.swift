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

import SwiftUI

public struct TodoListScreen: View {
    @Environment(\.viewController) private var viewController
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject var viewModel: TodoListViewModel

    public init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            refreshAction: { completion in
                viewModel.refresh(completion: completion, ignoreCache: true)
            }
        ) { _ in
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(viewModel.items) { group in
                    groupView(for: group)
                }
            }
            .paddingStyle(.horizontal, .standard)
        }
        .clipped()
        .navigationBarItems(leading: profileMenuButton)
    }

    @ViewBuilder
    private func groupView(for group: TodoGroup) -> some View {
        Section {
            ForEach(group.items) { item in
                TodoListItemCell(
                    item: item,
                    onTap: viewModel.didTapItem
                )
                .padding(.vertical, 8)
                .padding(.leading, 64)

                let isLastItemInGroup = (group.items.last == item)
                InstUI.Divider().padding(.leading, isLastItemInGroup ? 0 : 64)
            }
        } header: {
            TodoDayHeaderView(group: group)
                // move day badge to the left
                .frame(maxWidth: .infinity, alignment: .leading)
                // squeeze height to 0 so day badge goes next to cell
                .frame(height: 0, alignment: .top)
        }
    }

    private var profileMenuButton: some View {
        Button {
            viewModel.openProfile(viewController)
        } label: {
            Image.hamburgerSolid
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44)
        .padding(.leading, -6)
        .identifier("ToDos.profileButton")
        .accessibility(label: Text(
            "Profile Menu, Closed",
            bundle: .core,
            comment: "Accessibility text describing the Profile Menu button and its state"
        ))
    }
}

#if DEBUG

#Preview {
    let viewModel = TodoListViewModel(interactor: TodoInteractorPreview(), env: PreviewEnvironment())
    TodoListScreen(viewModel: viewModel)
}

#endif
