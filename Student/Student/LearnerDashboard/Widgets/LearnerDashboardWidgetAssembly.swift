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
    static func makeDefaultWidgetConfigs() -> [DashboardWidgetConfig] {
        let identifiers: [DashboardWidgetIdentifier] = [
            // full width
            .conferences,
            .courseInvitations,
            .globalAnnouncements,

            // grid
            .helloWidget,
            .coursesAndGroups
        ]

        return identifiers.enumerated().map { (index, id) in
            DashboardWidgetConfig(id: id, order: index, isVisible: true)
        }
    }

    static func makeWidgetViewModel(
        config: DashboardWidgetConfig,
        snackBarViewModel: SnackBarViewModel,
        coursesInteractor: CoursesInteractor = makeCoursesInteractor()
    ) -> any DashboardWidgetViewModel {
        switch config.id {
        case .conferences:
            ConferencesWidgetViewModel(
                config: config,
                interactor: .live(coursesInteractor: coursesInteractor, env: .shared),
                snackBarViewModel: snackBarViewModel
            )
        case .courseInvitations:
            CourseInvitationsWidgetViewModel(
                config: config,
                interactor: coursesInteractor,
                snackBarViewModel: snackBarViewModel
            )
        case .globalAnnouncements:
            GlobalAnnouncementsWidgetViewModel(
                config: config,
                interactor: .live(env: .shared)
            )
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

    @ViewBuilder
    static func makeView(for viewModel: any DashboardWidgetViewModel) -> some View {
        switch viewModel {
        case let vm as ConferencesWidgetViewModel:
            vm.makeView()
        case let vm as CourseInvitationsWidgetViewModel:
	        vm.makeView()
        case let vm as GlobalAnnouncementsWidgetViewModel:
            vm.makeView()
        case let vm as HelloWidgetViewModel:
            vm.makeView()
        case let vm as CoursesAndGroupsWidgetViewModel:
            vm.makeView()
        default:
            SwiftUI.EmptyView()
                .onAppear {
                    assertionFailure("Unknown widget view model type")
                }
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
