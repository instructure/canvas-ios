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

import Foundation
import Observation

@Observable
final class UnenrolledProgramListWidgetViewModel {
    private(set) var programs: [Program]
    private(set) var currentProgram: Program?
    private(set) var currentInex: Int = 0
    private(set) var isNextButtonEnabled: Bool = false
    private(set) var isPreviousButtonEnabled: Bool = false
    private(set) var isNavigationButtonVisible: Bool = false

    init(programs: [Program]) {
        self.programs = programs
        configureInitialState()
    }

    func updatePrograms(_ newPrograms: [Program]) {
        programs = newPrograms
        configureInitialState()
    }

    func goNextProgram() {
        guard !programs.isEmpty else { return }
        currentInex = min(currentInex + 1, programs.count - 1)
        currentProgram = programs[currentInex]
        updateButtonStates()
    }

    func goPreviousProgram() {
        guard !programs.isEmpty else { return }
        currentInex = max(currentInex - 1, 0)
        currentProgram = programs[currentInex]
        updateButtonStates()
    }

    private func configureInitialState() {
        currentInex = 0
        currentProgram = programs.first
        isNavigationButtonVisible = programs.count > 1
        updateButtonStates()
    }

    private func updateButtonStates() {
        guard !programs.isEmpty else {
            isNextButtonEnabled = false
            isPreviousButtonEnabled = false
            return
        }
        isNextButtonEnabled = currentInex < programs.count - 1
        isPreviousButtonEnabled = currentInex > 0
    }
}
