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

import Combine
import Core
import Observation

@Observable
final class CoursesAndGroupsWidgetSettingsViewModel {
    var showGrades: Bool {
        didSet { env.userDefaults?.showGradesOnDashboard = showGrades }
    }

    var showColorOverlay: Bool {
        didSet {
            updateColorOverlayTask = ReactiveStore(
                context: env.database.viewContext,
                useCase: UpdateUserSettings(hide_dashcard_color_overlays: !showColorOverlay),
                environment: env
            )
            .getEntities(ignoreCache: true)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        }
    }

    private var updateColorOverlayTask: AnyCancellable?
    private let env: AppEnvironment

    init(env: AppEnvironment) {
        self.env = env
        self.showGrades = env.userDefaults?.showGradesOnDashboard ?? false
        let settings: [UserSettings] = env.database.viewContext.fetch()
        self.showColorOverlay = !(settings.first?.hideDashcardColorOverlays ?? false)
    }
}
