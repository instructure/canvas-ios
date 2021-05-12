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

struct K5DashboardNavigationView: View {
    @ObservedObject private var viewModel: K5DashboardViewModel

    init(viewModel: K5DashboardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.navigationItems) { navigationItem in
                    Button(action: {
                        viewModel.currentNavigationItem = navigationItem
                    }, label: {
                        HStack {
                            navigationItem.icon
                            navigationItem.label
                        }
                    })
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}

struct K5DashboardNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        K5DashboardNavigationView(viewModel: K5DashboardViewModel())
            .previewLayout(.sizeThatFits)
    }
}
