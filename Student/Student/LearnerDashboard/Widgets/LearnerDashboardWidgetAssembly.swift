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
import SwiftUI

enum LearnerDashboardWidgetAssembly {
    static func makeDefaultEditableWidgetConfigs() -> [DashboardWidgetConfig] {
        EditableWidgetIdentifier.allCases.enumerated().map { (index, id) in
            DashboardWidgetConfig(id: id, order: index, isVisible: true)
        }
    }

    static func makeSystemWidgetViewModel(
        for widgetId: SystemWidgetIdentifier,
        snackBarViewModel: SnackBarViewModel,
        coursesInteractor: CoursesInteractor = makeCoursesInteractor()
    ) -> any DashboardWidgetViewModel {
        switch widgetId {
        case .offlineSyncProgress:
            OfflineSyncProgressWidgetViewModel(
                dashboardViewModel: DashboardOfflineSyncProgressCardAssembly.makeViewModel()
            )
        case .fileUploadProgress:
            FileUploadProgressWidgetViewModel(
                router: AppEnvironment.shared.router,
                listViewModel: FileUploadNotificationCardListViewModel()
            )
        case .courseInvitations:
            CourseInvitationsWidgetViewModel(
                interactor: coursesInteractor,
                snackBarViewModel: snackBarViewModel
            )
        case .globalAnnouncements:
            GlobalAnnouncementsWidgetViewModel(
                interactor: .live(env: .shared)
            )
        case .conferences:
            ConferencesWidgetViewModel(
                interactor: .live(coursesInteractor: coursesInteractor, env: .shared),
                snackBarViewModel: snackBarViewModel
            )
        }
    }

    static func makeEditableWidgetViewModel(
        config: DashboardWidgetConfig,
        snackBarViewModel: SnackBarViewModel,
        coursesInteractor: CoursesInteractor = makeCoursesInteractor()
    ) -> any DashboardWidgetViewModel {
        switch config.id {
        case .helloWidget:
            HelloWidgetViewModel(
                config: config,
                interactor: .live(),
                dayPeriodProvider: .init()
            )
        case .coursesAndGroups:
            CoursesAndGroupsWidgetViewModel(
                config: config,
                interactor: .live(coursesInteractor: coursesInteractor, env: .shared)
            )
        }
    }

    // MARK: - Cached Interactor Instance

    private static let lock = NSLock()
    private static weak var sharedCoursesInteractor: CoursesInteractorLive?

    internal static func makeCoursesInteractor() -> CoursesInteractorLive {
        lock.lock()
        defer { lock.unlock() }

        if let sharedCoursesInteractor {
            return sharedCoursesInteractor
        }

        let instance = CoursesInteractorLive(env: .shared)
        sharedCoursesInteractor = instance
        return instance
    }
}
