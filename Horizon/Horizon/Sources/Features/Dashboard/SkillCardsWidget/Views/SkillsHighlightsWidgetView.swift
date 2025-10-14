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

struct SkillsHighlightsWidgetView: View {
    // MARK: - Dependencies

    @State private var viewModel: SkillsHighlightsWidgetViewModel
    private let onTap: () -> Void

    // MARK: - Init

    init(viewModel: SkillsHighlightsWidgetViewModel,
         onTap: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onTap = onTap
    }

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            SkillsHighlightsWidgetHeaderView()
            switch viewModel.state {
            case .data:
                ForEach(viewModel.skills) { skill in
                    Button {
                        onTap()
                    } label: {
                        SkillHighlightWidgetView(skill: skill)
                    }
                    .accessibilityHint(String(localized: "Double tap to open skillspace", bundle: .horizon))
                }
            case .empty:
                SkillsHighlightsWidgetEmptyView()
            case .error:
                SkillsHighlightsWidgetErrorView {
                    viewModel.getSkills(ignoreCache: true)
                }
            case .loading:
                SkillHighlightWidgetView(skill: SkillWidgetModel.loadingModel)
            }
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
        .isSkeletonLoadActive(viewModel.state == .loading)
        .padding(.horizontal, .huiSpaces.space24)
        .padding(.top, .huiSpaces.space16)
        .onWidgetReload { completion in
            viewModel.getSkills(ignoreCache: true, completion: completion)
        }
    }
}

#if DEBUG
#Preview {
   VStack {
        SkillsHighlightsWidgetAssembly.makePreview(shouldReturnError: true)
       SkillsHighlightsWidgetAssembly.makePreview(shouldReturnError: false)
    }
}
#endif
