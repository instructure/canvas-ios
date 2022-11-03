//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

#if DEBUG

import Combine

class DashboardSettingsInteractorPreview: DashboardSettingsInteractor {

    // MARK: - Inputs & Outputs
    public let layout = CurrentValueSubject<DashboardLayout, Never>(.grid)
    public let showGrades = CurrentValueSubject<Bool, Never>(false)
    public let colorOverlay = CurrentValueSubject<Bool, Never>(false)

    // MARK: - Outputs
    public let isGradesSwitchVisible: Bool
    public let isColorOverlaySwitchVisible: Bool

    public init(isGradesSwitchVisible: Bool = true,
                isColorOverlaySwitchVisible: Bool = true) {
        self.isGradesSwitchVisible = isGradesSwitchVisible
        self.isColorOverlaySwitchVisible = isColorOverlaySwitchVisible
    }
}

#endif
