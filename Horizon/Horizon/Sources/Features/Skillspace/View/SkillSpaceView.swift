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

import HorizonUI
import SwiftUI

struct SkillSpaceView: View {
    let viewModel: HEmbeddedWebPageContainerViewModel

    var body: some View {
        HEmbeddedWebPageContainerView(viewModel: viewModel)
            .toolbar(.hidden)
            .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
            .background(Color.huiColors.surface.pagePrimary)
    }

    private var navigationBar: some View {
        HStack(spacing: .zero) {
            InstitutionLogo()
            Spacer()
        }
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space10)
        .padding(.bottom, .huiSpaces.space4)
    }
}
