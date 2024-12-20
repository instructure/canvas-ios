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

import Combine

public class DashboardSettingsInteractorLive: DashboardSettingsInteractor {

    // MARK: - Inputs & Outputs
    public let layout: CurrentValueSubject<DashboardLayout, Never>
    public let showGrades: CurrentValueSubject<Bool, Never>
    public let colorOverlay: CurrentValueSubject<Bool, Never>

    // MARK: - Outputs
    public let isGradesSwitchVisible: Bool
    public let isColorOverlaySwitchVisible: Bool

    // MARK: - Private
    private var defaults: SessionDefaults
    private var subscriptions = Set<AnyCancellable>()
    private var userSettings: Store<GetUserSettings>!

    public init(environment: AppEnvironment, defaults: SessionDefaults?) {
        let defaults = defaults ?? .fallback
        let storedLayout: DashboardLayout = defaults.isDashboardLayoutGrid ? .grid : .list
        self.defaults = defaults
        self.layout = CurrentValueSubject<DashboardLayout, Never>(storedLayout)
        self.showGrades = CurrentValueSubject<Bool, Never>(defaults.showGradesOnDashboard ?? false)
        self.colorOverlay = CurrentValueSubject<Bool, Never>(true)
        self.isGradesSwitchVisible = (environment.app == .student)
        self.isColorOverlaySwitchVisible = (environment.app == .student || environment.app == .teacher)
        self.userSettings = environment.subscribe(GetUserSettings(userID: "self")) { [weak self] in
            self?.updateColorOverlay()
        }
        userSettings.refresh()

        saveLayoutToDefaultsOnChange()
        saveGradesToDefaultsOnChange()
        saveOverlayOnChange()
        updateLayoutFromDefaultsOnChange()

        logAnalytics()
    }

    private func updateColorOverlay() {
        let colorOverlay = userSettings
            .first?
            .hideDashcardColorOverlays ?? false

        if self.colorOverlay.value != !colorOverlay {
            self.colorOverlay.send(!colorOverlay)
        }
    }

    private func saveLayoutToDefaultsOnChange() {
        layout
            .dropFirst()
            .map { $0 == .grid ? true : false }
            .sink { [weak self] isGrid in
                self?.defaults.isDashboardLayoutGrid = isGrid
            }
            .store(in: &subscriptions)
    }

    private func saveGradesToDefaultsOnChange() {
        showGrades
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] showGrades in
                self?.defaults.showGradesOnDashboard = showGrades
            }
            .store(in: &subscriptions)
    }

    private func saveOverlayOnChange() {
        colorOverlay
            .dropFirst()
            .removeDuplicates()
            .sink { colorOverlay in
                UpdateUserSettings(hide_dashcard_color_overlays: !colorOverlay).fetch()
            }
            .store(in: &subscriptions)
    }

    private func updateLayoutFromDefaultsOnChange() {
        NotificationCenter
            .default
            .publisher(for: UserDefaults.didChangeNotification)
            .map { [defaults] _ in
                defaults.isDashboardLayoutGrid ? DashboardLayout.grid : DashboardLayout.list
            }
            .filter { [layout] in
                $0 != layout.value
            }
            .subscribe(layout)
            .store(in: &subscriptions)
    }

    private func logAnalytics() {
        let type = layout.value == .grid ? "grid" : "list"
        Analytics.shared.logEvent("dashboard_layout", parameters: ["type": type])
    }
}
