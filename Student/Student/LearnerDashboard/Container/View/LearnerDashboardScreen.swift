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

struct LearnerDashboardScreen: View {
    @State private var viewModel: LearnerDashboardViewModel
    @Environment(\.viewController) private var viewController
    @Environment(\.appEnvironment) private var env

    init(viewModel: LearnerDashboardViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: viewModel.screenConfig,
            refreshAction: { completion in
                viewModel.refresh(
                    ignoreCache: true,
                    completion: completion
                )
            }
        ) { _ in
            content
        }
        .navigationBarDashboard()
        .toolbar {
            if #available(iOS 26, *) {
                ToolbarItem(placement: .topBarLeading) { profileMenuButton }
            } else {
                ToolbarItem(placement: .topBarLeading) { legacyProfileMenuButton }
            }
        }

    }

    @available(iOS, introduced: 26, message: "Legacy version exists")
    private var profileMenuButton: some View {
        Button {
            env.router.route(to: "/profile", from: viewController, options: .modal())
        } label: {
            Image.hamburgerSolid
        }
        .identifier("Dashboard.profileButton")
        .accessibility(label: Text("Profile Menu, Closed", bundle: .core, comment: "Accessibility text describing the Profile Menu button and its state"))
    }

    @available(iOS, deprecated: 26, message: "Non-legacy version exists")
    private var legacyProfileMenuButton: some View {
        Button {
            env.router.route(to: "/profile", from: viewController, options: .modal())
        } label: {
            Image.hamburgerSolid
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
        .identifier("Dashboard.profileButton")
        .accessibility(label: Text("Profile Menu, Closed", bundle: .core, comment: "Accessibility text describing the Profile Menu button and its state"))
    }


    @ViewBuilder
    private var content: some View {
        DashboardWidgetLayout(
            fullWidthWidgets: viewModel.fullWidthWidgets,
            gridWidgets: viewModel.gridWidgets
        )
        .paddingStyle(.all, .standard)
    }
}

#if DEBUG

#Preview {
    let controller = CoreHostingController(
        LearnerDashboardAssembly.makeScreen()
    )
    CoreNavigationController(rootViewController: controller)
}

#endif
