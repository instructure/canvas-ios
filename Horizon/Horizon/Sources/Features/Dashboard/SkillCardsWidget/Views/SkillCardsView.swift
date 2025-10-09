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

struct SkillCardsView: View {
    // MARK: - Dependencies

    @State private var viewModel: SkillCardsViewModel
    private let onTap: () -> Void

    // MARK: - Init

    init(viewModel: SkillCardsViewModel,
         onTap: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            SkillHeaderView()
            switch viewModel.state {
            case .data(let skills):
                ForEach(skills) { skill in
                    Button {
                        onTap()
                    } label: {
                        SkillCardView(skill: skill)
                    }
                }
            case .empty:
                SkillsEmptyView()
            case .error:
                SkillsErrorView {
                    viewModel.getSkills(ignoreCache: true)
                }
            case .loading:
                SkillCardView(skill: SkillCardModel.loadingModel)
            }
        }
        .padding(.huiSpaces.space24)
        .background {
            RoundedRectangle(cornerRadius: HorizonUI.CornerRadius.level4.attributes.radius)
                .fill(Color.huiColors.primitives.white10)
                .accessibilityHidden(true)
        }
        .huiElevation(level: .level4)
        .isSkeletonLoadActive(viewModel.state == .loading)
    }

    func reload() {
        viewModel.getSkills(ignoreCache: true)
    }
}

#if DEBUG
#Preview {
    SkillCardsAssembly.makePreview()
}
#endif
