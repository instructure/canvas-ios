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
import SwiftUI

struct SkillsHighlightsWidgetAssembly {
    static func makeViewModel() -> SkillsHighlightsWidgetViewModel {
        let interactor = SkillsWidgetInteractorLive()
        return SkillsHighlightsWidgetViewModel(interactor: interactor)
    }

    static func makeView(viewModel: SkillsHighlightsWidgetViewModel) -> SkillsHighlightsWidgetView {
        let onTapSkillSpace: () -> Void = { AppEnvironment.shared.switchToSkillSpaceTab() }
        return SkillsHighlightsWidgetView(viewModel: viewModel, onTap: onTapSkillSpace)
    }

#if DEBUG
    static func makePreview(shouldReturnError: Bool) -> SkillsHighlightsWidgetView {
        let interactor = SkillsWidgetInteractorPreview(shouldReturnError: shouldReturnError)
        let viewModel = SkillsHighlightsWidgetViewModel(interactor: interactor)
        return SkillsHighlightsWidgetView(viewModel: viewModel) {}
    }
#endif
}

extension AppEnvironment {
    func switchToSkillSpaceTab() {
        switchToTab(at: HorizonTabBarType.skillspace.index)
    }
}
