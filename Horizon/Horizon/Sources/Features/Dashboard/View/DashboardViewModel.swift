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

import Combine
import Core
import Foundation

final class DashboardViewModel: ObservableObject {
    // MARK: - Outputs

    @Published private(set) var state: InstUI.ScreenState = .loading
    @Published private(set) var title: String = "Welcome back, Justine"
    @Published private(set) var program: HProgram?

    // MARK: - Private variables

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    init(interactor: GetProgramsInteractor) {
        unowned let unownedSelf = self

        interactor.getPrograms()
            .compactMap { $0.first }
            .sink { program in
                unownedSelf.program = program
                unownedSelf.state = .data
            }
            .store(in: &subscriptions)
    }
}
