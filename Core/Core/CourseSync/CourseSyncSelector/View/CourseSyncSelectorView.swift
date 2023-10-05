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

struct CourseSyncSelectorView: View {
    @Environment(\.viewController) var viewController
    @StateObject var viewModel: CourseSyncSelectorViewModel
    @StateObject var diskSpaceViewModel: CourseSyncDiskSpaceInfoViewModel

    var body: some View {
        content
        .background(Color.backgroundLightest)
        .navigationTitleStyled(navBarTitleView)
        .navigationBarItems(leading: leftNavBarButton, trailing: cancelButton)
        .navigationBarStyle(.modal)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .error:
            InteractivePanda(scene: NoResultsPanda(),
                             title: Text(viewModel.labels.error.title),
                             subtitle: Text(viewModel.labels.error.message))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loading:
            ProgressView()
                .progressViewStyle(.indeterminateCircle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .data:
            VStack(spacing: 0) {
                CourseSyncDiskSpaceInfoView(viewModel: diskSpaceViewModel)
                    .padding(16)
                Divider()
                GeometryReader { geometry in
                    ScrollView {
                        if viewModel.cells.isEmpty {
                            emptyList(geometry: geometry)
                        } else {
                            listCells
                        }
                    }
                }
                syncButton
            }
            .confirmationAlert(isPresented: $viewModel.isShowingConfirmationDialog,
                               presenting: viewModel.confirmAlert)
        }
    }

    private var listCells: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.cells) { cell in
                let isListItem: Bool = {
                    if case .item(let item) = cell, item.cellStyle == .listItem {
                        return true
                    } else {
                        return false
                    }
                }()

                VStack(spacing: 0) {
                    switch cell {
                    case .item(let item):
                        ListCellView(ListCellViewModel(cellStyle: item.cellStyle,
                                                       title: item.title,
                                                       subtitle: item.subtitle,
                                                       selectionState: item.selectionState,
                                                       isCollapsed: item.isCollapsed,
                                                       selectionDidToggle: item.selectionDidToggle,
                                                       collapseDidToggle: item.collapseDidToggle,
                                                       state: .idle))
                    case .empty:
                        emptyCourse
                    }
                    Divider().padding(.leading, isListItem ? 74 : 0)
                }.padding(.leading, isListItem ? 24 : 0)
            }
        }
        .animation(.default, value: viewModel.cells)
    }

    private func emptyList(geometry: GeometryProxy) -> some View {
        InteractivePanda(scene: SpacePanda(),
                         title: Text(viewModel.labels.noCourses.title),
                         subtitle: Text(viewModel.labels.noCourses.message))

        .padding(16)
        .frame(maxWidth: .infinity, minHeight: geometry.size.height)
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
            Text(viewModel.navBarSubtitle)
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

    private var syncButton: some View {
        Button {
            viewModel.syncButtonDidTap.accept(viewController)
        } label: {
            Text("Sync", bundle: .core)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .font(.regular16, lineHeight: .fit)
                .foregroundColor(.textLightest)
                .background(Color(Brand.shared.primary))
                .opacity(viewModel.syncButtonDisabled ? 0.42 : 1)
        }
        .disabled(viewModel.syncButtonDisabled)
    }

    @ViewBuilder
    private var leftNavBarButton: some View {
        if viewModel.leftNavBarButtonVisible {
            Button {
                viewModel.leftNavBarButtonDidTap.accept()
            } label: {
                Text(viewModel.leftNavBarTitle)
                    .font(.regular16)
                    .foregroundColor(.textDarkest)
            }
        }
    }
}

struct SeparatorView: View {
    let isLight: Bool
    let isIndented: Bool

    var body: some View {
        Rectangle()
            .fill(isLight ? Color.borderMedium : Color.borderDark)
            .frame(height: 1)
            .padding(.leading, isIndented ? 16 : 0)
    }
}

#if DEBUG

struct CourseSyncSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSyncSelectorAssembly
            .makePreview(env: AppEnvironment.shared, isEmpty: false)
            .previewDisplayName("Data")
        CourseSyncSelectorAssembly
            .makePreview(env: AppEnvironment.shared, isEmpty: true)
            .previewDisplayName("Empty List")
    }
}

#endif
