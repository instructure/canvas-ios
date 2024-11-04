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

import Foundation
import Core

final class DashboardAssembly {
    static func makeGetProgramsInteractor() -> GetProgramsInteractor {
        GetProgramsInteractorLive(appEnvironment: AppEnvironment.shared)
    }
    static func makeView() -> DashboardView {
        DashboardView(viewModel: .init(interactor: makeGetProgramsInteractor()))
    }

#if DEBUG
    static func makePreview() -> DashboardView {
        let interactor = GetProgramsInteractorPreview()
        let viewModel = DashboardViewModel(interactor: interactor)
        return DashboardView(viewModel: viewModel)
    }
#endif
}
