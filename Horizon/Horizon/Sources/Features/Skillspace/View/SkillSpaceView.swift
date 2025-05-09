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
import HorizonUI

struct SkillSpaceView: View {
    // TODO: - Set with correct url later
    private let logoURL = "https://cdn.prod.website-files.com/5f7685be6c8c113f558855d9/62c87dbd6208a1e98e89e707_Logo_Canvas_Red_Vertical%20copy.png"

    let viewModel: HEmbeddedWebPageContainerViewModel

    var body: some View {
        HEmbeddedWebPageContainerView(viewModel: viewModel)
            .toolbar(.hidden)
            .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
    }

    private var navigationBar: some View {
        HStack(spacing: .zero) {
            HorizonUI.NavigationBar.Leading(logoURL: logoURL)
            Spacer()
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.bottom, .huiSpaces.space4)
    }
}
