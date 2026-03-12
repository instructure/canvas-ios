//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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
import Observation
import SwiftUI

@Observable
final class LearnerDashboardCourseSettingsViewModel {
    var configs: [Config]

    // Example username for preview and accessibility labels
    let username = "Riley"

    init(configs: [Config]) {
        let visibleConfigs = configs.filter { $0.isVisible }.sorted()
        let hiddenConfigs = configs.filter { !$0.isVisible }.sorted()

        self.configs = visibleConfigs + hiddenConfigs
    }

    func toggleVisibility(of config: Config, to isVisible: Bool) {
        guard let index = configs.firstIndex(of: config) else { return }

        configs[index].isVisible = isVisible

        let visibleConfigs = configs.filter { $0.isVisible }
        let hiddenConfigs = configs.filter { !$0.isVisible }

        withAnimation {
            configs = visibleConfigs + hiddenConfigs
        }
    }

    func moveUp(_ config: Config) {
        guard let index = configs.firstIndex(of: config), index > configs.startIndex else { return }
        let previousConfigIndex = configs.index(before: index)

        withAnimation {
            configs.swapAt(index, previousConfigIndex)
        }
    }

    func isMoveUpDisabled(of config: Config) -> Bool {
        guard let index = configs.firstIndex(of: config), index > configs.startIndex else { return true }

        return !config.isVisible
    }

    func moveDown(_ config: Config) {
        guard let index = configs.firstIndex(of: config), index < configs.endIndex - 1 else { return }
        let nextConfigIndex = configs.index(after: index)

        withAnimation {
            configs.swapAt(index, nextConfigIndex)
        }
    }

    func isMoveDownDisabled(of config: Config) -> Bool {
        guard let index = configs.firstIndex(of: config), index < configs.endIndex - 1 else { return true }
        let nextConfigIndex = configs.index(after: index)

        return !configs[nextConfigIndex].isVisible || !config.isVisible
    }
}

extension LearnerDashboardCourseSettingsViewModel {
    typealias Config = DashboardWidgetConfig
}
