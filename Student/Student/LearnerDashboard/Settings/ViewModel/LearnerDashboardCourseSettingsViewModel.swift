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
import Foundation
import Observation
import SwiftUI

@Observable
final class LearnerDashboardCourseSettingsViewModel {
    var visibleConfigs: [Config]
    var hiddenConfigs: [Config]
    let username: String
    let subSettingsViews: [EditableWidgetIdentifier: AnyView]

    var configs: [Config] { visibleConfigs + hiddenConfigs }

    private var userDefaults: SessionDefaults
    private let onConfigsChanged: () -> Void

    init(
        userDefaults: SessionDefaults,
        configs: [Config],
        username: String,
        subSettingsViews: [EditableWidgetIdentifier: AnyView] = [:],
        onConfigsChanged: @escaping () -> Void
    ) {
        self.userDefaults = userDefaults
        self.username = username
        self.subSettingsViews = subSettingsViews
        self.onConfigsChanged = onConfigsChanged
        visibleConfigs = configs.filter { $0.isVisible }.sorted()
        hiddenConfigs = configs.filter { !$0.isVisible }.sorted()
    }

    func toggleVisibility(of config: Config, to isVisible: Bool) {
        if isVisible {
            guard let index = hiddenConfigs.firstIndex(of: config) else { return }
            var toggledConfig = hiddenConfigs.remove(at: index)
            toggledConfig.isVisible = isVisible
            visibleConfigs.append(toggledConfig)
        } else {
            guard let index = visibleConfigs.firstIndex(of: config) else { return }
            var toggledConfig = visibleConfigs.remove(at: index)
            toggledConfig.isVisible = isVisible
            hiddenConfigs.insert(toggledConfig, at: 0)
        }
        saveAndNotify()
    }

    func moveUp(_ config: Config) {
        guard let index = visibleConfigs.firstIndex(of: config), index > visibleConfigs.startIndex else { return }
        let previousConfigIndex = visibleConfigs.index(before: index)
        withAnimation(.dashboardWidget) {
            visibleConfigs.swapAt(index, previousConfigIndex)
        }
        saveAndNotify()
    }

    func isMoveUpDisabled(of config: Config) -> Bool {
        guard let index = visibleConfigs.firstIndex(of: config) else { return true }
        return index == visibleConfigs.startIndex
    }

    func moveDown(_ config: Config) {
        guard let index = visibleConfigs.firstIndex(of: config), index < visibleConfigs.endIndex - 1 else { return }
        let nextConfigIndex = visibleConfigs.index(after: index)
        withAnimation(.dashboardWidget) {
            visibleConfigs.swapAt(index, nextConfigIndex)
        }
        saveAndNotify()
    }

    func isMoveDownDisabled(of config: Config) -> Bool {
        guard let index = visibleConfigs.firstIndex(of: config) else { return true }
        return index == visibleConfigs.endIndex - 1
    }

    private func saveAndNotify() {
        let updatedVisible = visibleConfigs.enumerated().map { (index, config) -> Config in
            var updated = config
            updated.order = index
            return updated
        }
        let updatedHidden = hiddenConfigs.enumerated().map { (index, config) -> Config in
            var updated = config
            updated.order = visibleConfigs.count + index
            return updated
        }
        userDefaults.learnerDashboardWidgetConfigs = updatedVisible + updatedHidden
        onConfigsChanged()
    }
}

extension LearnerDashboardCourseSettingsViewModel {
    typealias Config = DashboardWidgetConfig
}
