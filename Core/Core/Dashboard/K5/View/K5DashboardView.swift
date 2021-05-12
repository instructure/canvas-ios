//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public struct K5DashboardView: View {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel = K5DashboardViewModel()

    public var body: some View {
        VStack {
            K5DashboardNavigationView(viewModel: viewModel)
            Divider()
            ScrollView(.vertical) {
                content
            }
        }
        .navigationBarGlobal()
        .navigationBarItems(
            leading: Button(action: {
                viewModel.profileButtonPressed(router: env.router, viewController: controller)
            }, label: {
                Image.hamburgerSolid
                    .foregroundColor(Color(Brand.shared.navTextColor.ensureContrast(against: Brand.shared.navBackground)))
            })
                .identifier("Dashboard.profileButton")
                .accessibility(label: Text("Profile Menu", bundle: .core))
        )
    }

    @ViewBuilder private var content: some View {
        VStack(spacing: 0) {
            switch viewModel.currentNavigationItem.type {
            case .homeroom:
                CircleRefresh { endRefreshing in
                    viewModel.viewModels.homeroom.refresh(completion: endRefreshing)
                }
                K5HomeroomView()
            case .schedule:
                CircleRefresh { endRefreshing in
                    viewModel.viewModels.schedule.refresh(completion: endRefreshing)
                }
                K5ScheduleView(viewModel: viewModel.viewModels.schedule)
            case .grades:
                CircleRefresh { endRefreshing in
                    viewModel.viewModels.grades.refresh(completion: endRefreshing)
                }
                K5GradesView()
            case .resources:
                CircleRefresh { endRefreshing in
                    viewModel.viewModels.resources.refresh(completion: endRefreshing)
                }
                K5ResourcesView()
            }
        }
    }

    public init() {
    }
}

struct K5DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        K5DashboardView()
    }
}
