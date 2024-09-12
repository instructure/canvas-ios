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

import Core
import Foundation

protocol DashboardViewModel {
    var state: InstUI.ScreenState { get }
    var title: String { get }
    var progressionString: String { get }
    var progression: Double { get }
    var modules: [Module] { get }
}

public final class DashboardViewModelLive: DashboardViewModel, ObservableObject {
    // MARK: - Outputs

    @Published public private(set) var state: InstUI.ScreenState = .empty
    @Published public private(set) var title: String = "Welcome back, Justine"
    @Published public private(set) var progressionString: String = "75%"
    @Published public private(set) var progression: Double = 0.75
    @Published public private(set) var modules: [Module] = []

    // MARK: - Init

    init() {}
}
