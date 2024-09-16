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

final class ProgramsViewModel: ObservableObject {
    // MARK: - Outputs

    @Published private(set) var state: InstUI.ScreenState = .data(loadingOverlay: false)
    @Published private(set) var title: String = "Biology certificate"
    @Published private(set) var progressString: String = "75%"
    @Published private(set) var progress: Double = 0.75
    @Published private(set) var institutionName: String = "Community College"
    @Published private(set) var targetCompletion: String = "Target Completion: 2024/11/27"

    @Published private(set) var modules: [Module] = []
    
    // MARK: - Init

    init() {}
}
