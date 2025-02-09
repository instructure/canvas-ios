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
    @StateObject private var offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())

    var body: some View {
        content
            .navigationBarTitleView(
                title: String(localized: "Offline Content", bundle: .core),
                subtitle: String(localized: "All Courses", bundle: .core)
            )
            .navigationBarItems(leading: cancelButton, trailing: trailingBarItem)
            .navigationBarStyle(.modal)
            .confirmationAlert(
                isPresented: $viewModel.isShowingCancelDialog,
                presenting: viewModel.confirmAlert
            )
            .onAppear {
                viewModel.viewOnAppear.accept(viewController)
            }
    }

    @ViewBuilder
    private var trailingBarItem: some View {
        switch viewModel.state {
        case .dataWithError:
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
        case .data, .dataWithError:
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

    private var cancelButton: some View {
        Button {
            viewModel.cancelButtonDidTap.accept()
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
        .disabled(viewModel.isSyncFinished)
        .opacity(viewModel.isSyncFinished ? 0.5 : 1)
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
        PrimaryButton(isUnavailable: $offlineModeViewModel.isOffline) {
            viewModel.retryButtonDidTap.accept(())
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
            case let .loading(progress):
                OfflineListCellView(OfflineListCellViewModel(cellStyle: item.cellStyle,
                                               title: item.title,
                                               subtitle: item.subtitle,
                                               isCollapsed: item.isCollapsed,
                                               collapseDidToggle: item.collapseDidToggle,
                                               removeItemPressed: item.removeItemPressed,
                                               state: .loading(progress)))
            case .downloaded:
                OfflineListCellView(OfflineListCellViewModel(cellStyle: item.cellStyle,
                                               title: item.title,
                                               subtitle: item.subtitle,
                                               isCollapsed: item.isCollapsed,
                                               collapseDidToggle: item.collapseDidToggle,
                                               removeItemPressed: item.removeItemPressed,
                                               state: .downloaded))
            case .error:
                OfflineListCellView(OfflineListCellViewModel(cellStyle: item.cellStyle,
                                               title: item.title,
                                               subtitle: item.subtitle,
                                               isCollapsed: item.isCollapsed,
                                               collapseDidToggle: item.collapseDidToggle,
                                               removeItemPressed: item.removeItemPressed,
                                               state: .error(String(localized: "Sync Failed", bundle: .core))))
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
