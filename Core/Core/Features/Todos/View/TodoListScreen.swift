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
    /// The sticky section header grows horizontally, so we need to increase paddings here not to let the header overlap the cell content.
    @ScaledMetric private var uiScale: CGFloat = 1

    public init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: viewModel.screenConfig,
            refreshAction: { completion in
                viewModel.refresh(completion: completion, ignoreCache: true)
            }
        ) { _ in
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                InstUI.TopDivider()
                ForEach(viewModel.items) { group in
                    groupView(for: group)
                }
                InstUI.Divider()
            }
        }
        .clipped()
        .navigationBarItems(leading: profileMenuButton)
        .snackBar(viewModel: viewModel.snackBar)
    }

    @ViewBuilder
    private func groupView(for group: TodoGroupViewModel) -> some View {
        Section {
            let leadingPadding = TodoDayHeaderView.headerWidth(uiScale)
            ForEach(group.items) { item in
                TodoListItemCell(
                    item: item,
                    onTap: viewModel.didTapItem,
                    onMarkAsDone: viewModel.markItemAsDone,
                    onSwipeMarkAsDone: viewModel.markItemAsDoneWithOptimisticUI
                )
                .padding(.leading, leadingPadding)
                .transition(.asymmetric(
                    insertion: .identity,
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                let isLastItemInGroup = (group.items.last == item)

                if !isLastItemInGroup {
                    InstUI.Divider()
                        .padding(.leading, leadingPadding)
                        .paddingStyle(.trailing, .standard)
                }
            }
        } header: {
            VStack(spacing: 0) {
                let isFirstSection = (viewModel.items.first == group)

                if !isFirstSection {
                    InstUI.Divider().paddingStyle(.horizontal, .standard)
                }

                TodoDayHeaderView(group: group) { group in
                    viewModel.didTapDayHeader(group, viewController: viewController)
                }
                // Move day badge to the left of the screen.
                .frame(maxWidth: .infinity, alignment: .leading)
                // Squeeze height to 0 so day badge goes next to cell.
                .frame(height: 0, alignment: .top)
            }
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
    let env = PreviewEnvironment()
    let viewModel = TodoListViewModel(interactor: TodoInteractorPreview(), router: env.router)
    TodoListScreen(viewModel: viewModel)
}

#Preview("Empty State") {
    let env = PreviewEnvironment()
    let viewModel = TodoListViewModel(interactor: TodoInteractorPreview(todoGroups: []), router: env.router)
    TodoListScreen(viewModel: viewModel)
}

#endif
