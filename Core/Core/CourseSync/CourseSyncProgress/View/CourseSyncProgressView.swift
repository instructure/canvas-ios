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
        .navigationBarTitleView(navBarTitleView)
        .navigationBarStyle(.modal)
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
                        ForEach(viewModel.items) { item in
                            VStack(spacing: 0) {
                                ListCellView(ListCellViewModel(cellStyle: item.cellStyle,
                                                          title: item.title,
                                                          subtitle: item.subtitle,
                                                          isCollapsed: item.isCollapsed,
                                                          collapseDidToggle: item.collapseDidToggle,
                                                          removeItemPressed: item.removeItemPressed,
                                                          progress: item.progress,
                                                          error: item.error))
                                Divider().padding(.leading, item.cellStyle == .listItem ? item.progress != nil ? 16 : 74 : 0)
                            }.padding(.leading, item.cellStyle == .listItem ? 24 : 0)
                        }
                    }
                }.animation(.default, value: viewModel.items)
            }
            .background(Color.backgroundLightest)
        }
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
            env.router.dismiss(viewController)
        } label: {
            Text("Cancel", bundle: .core)
                .font(.regular16)
                .foregroundColor(.textDarkest)
        }
    }
}

#if DEBUG

struct CourseSyncProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CourseSyncProgressAssembly.makePreview(env: AppEnvironment.shared)
    }
}

#endif
