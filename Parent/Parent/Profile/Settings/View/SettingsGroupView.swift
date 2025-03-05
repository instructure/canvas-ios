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
import Core

public struct SettingsGroupView: View {
    @ObservedObject var viewModel: SettingsGroupViewModel

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            getGroupTitleView(title: viewModel.title)

            ForEach(viewModel.itemViews, id: \.viewModel.id) { view in
                VStack(alignment: .leading, spacing: 0) {
                    Separator()

                    view

                    if (view.viewModel.id == viewModel.itemViews.last?.viewModel.id) {
                        Separator()
                    }
                }
            }
        }
    }

    private func getGroupTitleView(title: String) -> some View {
        return Text(title)
            .font(.regular14)
            .foregroundStyle(Color.textDark)
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }
}

#Preview {
    let viewModel = SettingsGroupViewModel(title: "Preferences", itemViews: [])
    SettingsGroupView(viewModel: viewModel)
}
