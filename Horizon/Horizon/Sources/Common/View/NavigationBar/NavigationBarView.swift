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

import Core
import HorizonUI
import Observation
import SwiftUI

struct NavigationBarView<Content: View>: View {

    // MARK: - Dependencies

    private let content: Content
    private let refreshable: Bool
    private let state: InstUI.ScreenState
    private let viewModel: NavigationBarViewModel

    // MARK: - Private

    private let logoURL = "https://cdn.prod.website-files.com/5f7685be6c8c113f558855d9/62c87dbd6208a1e98e89e707_Logo_Canvas_Red_Vertical%20copy.png"
    @Environment(\.viewController) private var viewController

    // MARK: - Init

    init(
        state: InstUI.ScreenState,
        viewModel: NavigationBarViewModel,
        refreshable: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.viewModel = viewModel
        self.refreshable = refreshable
        self.content = content()
    }

    var body: some View {
        InstUI.BaseScreen(
            state: state,
            config: .init(
                refreshable: refreshable,
                loaderBackgroundColor: .huiColors.surface.pagePrimary
            )
        ) { _ in
            content
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading: HorizonUI.NavigationBar.Leading(logoURL: logoURL))
        .navigationBarItems(trailing: HorizonUI.NavigationBar.Trailing {
            viewModel.notebookDidTap(viewController: viewController)
        } onNotificationDidTap: {
            viewModel.notificationsDidTap()
        } onMailDidTap: {
            viewModel.mailDidTap(viewController: viewController)
        })
        .scrollIndicators(.hidden, axes: .vertical)
        .background(Color.huiColors.surface.pagePrimary)
    }
}
