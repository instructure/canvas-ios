//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

struct CourseSyncProgressView: View {
    @Environment(\.appEnvironment) var env
    @Environment(\.viewController) var viewController
    @StateObject var viewModel: CourseSyncProgressViewModel
    @StateObject var courseSyncProgressInfoViewModel: CourseSyncProgressInfoViewModel

    var body: some View {
        content
        .navigationTitleStyled(navBarTitleView)
        .navigationBarItems(leading: cancelButton, trailing: trailingBarItem)
        .navigationBarStyle(.modal)
    }

    @ViewBuilder
    private var trailingBarItem: some View {
        switch viewModel.state {
        case .error:
            retryButton
        default:
            dismissButton
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .error:
            InteractivePanda(scene: NoResultsPanda(),
                             title: Text("Something went wrong", bundle: .core),
                             subtitle: Text("There was an unexpected error.", bundle: .core))
        case .loading:
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
        case .data:
            VStack(spacing: 0) {
                CourseSyncProgressInfoView(viewModel: courseSyncProgressInfoViewModel)
                    .padding(16)
                Divider()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.cells) { cell in
                            switch cell {
                            case let .item(item):
                                listCell(for: item)
                            case .empty:
                                emptyCourse
                            }
                        }
                    }
                }
                .animation(.default, value: viewModel.cells)
                .background(Color.backgroundLightest)
            }
        }
    }

    private var emptyCourse: some View {
        InteractivePanda(scene: SpacePanda(),
                         title: Text(viewModel.labels.noItems.title),
                         subtitle: Text(viewModel.labels.noItems.message))
            .allowsHitTesting(false)
            .padding(.horizontal, 16)
            .padding(.vertical, 32)
    }

    private var navBarTitleView: some View {
        VStack(spacing: 1) {
            Text("Offline Content", bundle: .core)
                .font(.semibold16)
                .foregroundColor(.textDarkest)
            Text("All Courses", bundle: .core)
                .font(.regular12)
                .foregroundColor(.textDark)
        }
    }

    private var cancelButton: some View {
        Button {
            viewModel.cancelButtonDidTap.accept(viewController)
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
    }

    private var dismissButton: some View {
        Button {
            viewModel.dismissButtonDidTap.accept(viewController)
        } label: {
            Text("Dismiss", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
    }

    private var retryButton: some View {
        Button {
            viewModel.retryButtonDidTap.accept(viewController)
        } label: {
            Text("Retry", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
    }

    @ViewBuilder
    private func listCell(for item: CourseSyncProgressViewModel.Item) -> some View {
        VStack(spacing: 0) {
            switch item.state {
            case .idle:
                ListCellView(ListCellViewModel(cellStyle: item.cellStyle,
                                               title: item.title,
                                               subtitle: item.subtitle,
                                               isCollapsed: item.isCollapsed,
                                               collapseDidToggle: item.collapseDidToggle,
                                               removeItemPressed: item.removeItemPressed,
                                               state: .idle))
            case let .loading(progress):
                ListCellView(ListCellViewModel(cellStyle: item.cellStyle,
                                               title: item.title,
                                               subtitle: item.subtitle,
                                               isCollapsed: item.isCollapsed,
                                               collapseDidToggle: item.collapseDidToggle,
                                               removeItemPressed: item.removeItemPressed,
                                               state: .loading(progress)))
            case .downloaded:
                ListCellView(ListCellViewModel(cellStyle: item.cellStyle,
                                               title: item.title,
                                               subtitle: item.subtitle,
                                               isCollapsed: item.isCollapsed,
                                               collapseDidToggle: item.collapseDidToggle,
                                               removeItemPressed: item.removeItemPressed,
                                               state: .downloaded))
            case .error:
                ListCellView(ListCellViewModel(cellStyle: item.cellStyle,
                                               title: item.title,
                                               subtitle: item.subtitle,
                                               isCollapsed: item.isCollapsed,
                                               collapseDidToggle: item.collapseDidToggle,
                                               removeItemPressed: item.removeItemPressed,
                                               state: .error(NSLocalizedString("Sync Failed", bundle: .core, comment: ""))))
            }
            Divider().padding(.leading, item.cellStyle == .listItem ? 16 : 0)
        }.padding(.leading, item.cellStyle == .listItem ? 24 : 0)
    }
}

#if DEBUG

struct CourseSyncProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSyncProgressAssembly.makePreview(router: AppEnvironment.shared.router)
    }
}

#endif
