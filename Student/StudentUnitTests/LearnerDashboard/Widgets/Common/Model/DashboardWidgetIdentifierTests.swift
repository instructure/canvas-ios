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

@testable import Core
@testable import Student
import XCTest

final class DashboardWidgetIdentifierTests: StudentTestCase {

    // MARK: - EditableWidgetIdentifier.makeDefaultConfigs

    func test_makeDefaultConfigs_returnsOneConfigPerCase() {
        let configs = EditableWidgetIdentifier.makeDefaultConfigs()
        XCTAssertEqual(configs.count, EditableWidgetIdentifier.allCases.count)
    }

    func test_makeDefaultConfigs_configsAreAllVisible() {
        let configs = EditableWidgetIdentifier.makeDefaultConfigs()
        XCTAssertTrue(configs.allSatisfy { $0.isVisible })
    }

    func test_makeDefaultConfigs_orderMatchesDeclarationOrder() {
        let configs = EditableWidgetIdentifier.makeDefaultConfigs()
        let expectedIDs = EditableWidgetIdentifier.allCases

        for (index, config) in configs.enumerated() {
            XCTAssertEqual(config.id, expectedIDs[index])
            XCTAssertEqual(config.order, index)
        }
    }

    // MARK: - SystemWidgetIdentifier.makeViewModel

    func test_systemMakeViewModel_returnsViewModelWithMatchingID() {
        let snackBarViewModel = SnackBarViewModel()
        let coursesInteractor = CoursesInteractorLive(env: env)

        for identifier in SystemWidgetIdentifier.allCases {
            let viewModel = identifier.makeViewModel(
                snackBarViewModel: snackBarViewModel,
                coursesInteractor: coursesInteractor
            )
            XCTAssertEqual(viewModel.id, identifier.rawValue, "id mismatch for \(identifier)")
        }
    }

    func test_systemMakeViewModel_offlineSyncProgress_returnsCorrectType() {
        let viewModel = SystemWidgetIdentifier.offlineSyncProgress.makeViewModel(
            snackBarViewModel: SnackBarViewModel(),
            coursesInteractor: CoursesInteractorLive(env: env)
        )
        XCTAssertTrue(viewModel is OfflineSyncProgressWidgetViewModel)
    }

    func test_systemMakeViewModel_fileUploadProgress_returnsCorrectType() {
        let viewModel = SystemWidgetIdentifier.fileUploadProgress.makeViewModel(
            snackBarViewModel: SnackBarViewModel(),
            coursesInteractor: CoursesInteractorLive(env: env)
        )
        XCTAssertTrue(viewModel is FileUploadProgressWidgetViewModel)
    }

    func test_systemMakeViewModel_courseInvitations_returnsCorrectType() {
        let viewModel = SystemWidgetIdentifier.courseInvitations.makeViewModel(
            snackBarViewModel: SnackBarViewModel(),
            coursesInteractor: CoursesInteractorLive(env: env)
        )
        XCTAssertTrue(viewModel is CourseInvitationsWidgetViewModel)
    }

    func test_systemMakeViewModel_globalAnnouncements_returnsCorrectType() {
        let viewModel = SystemWidgetIdentifier.globalAnnouncements.makeViewModel(
            snackBarViewModel: SnackBarViewModel(),
            coursesInteractor: CoursesInteractorLive(env: env)
        )
        XCTAssertTrue(viewModel is GlobalAnnouncementsWidgetViewModel)
    }

    func test_systemMakeViewModel_conferences_returnsCorrectType() {
        let viewModel = SystemWidgetIdentifier.conferences.makeViewModel(
            snackBarViewModel: SnackBarViewModel(),
            coursesInteractor: CoursesInteractorLive(env: env)
        )
        XCTAssertTrue(viewModel is ConferencesWidgetViewModel)
    }

    // MARK: - EditableWidgetIdentifier.makeViewModel

    func test_editableMakeViewModel_returnsViewModelWithMatchingID() {
        let snackBarViewModel = SnackBarViewModel()
        let coursesInteractor = CoursesInteractorLive(env: env)

        for identifier in EditableWidgetIdentifier.allCases {
            let config = DashboardWidgetConfig(id: identifier, order: 0, isVisible: true)
            let viewModel = identifier.makeViewModel(
                config: config,
                snackBarViewModel: snackBarViewModel,
                coursesInteractor: coursesInteractor
            )
            XCTAssertEqual(viewModel.id, identifier.rawValue, "id mismatch for \(identifier)")
        }
    }

    func test_editableMakeViewModel_helloWidget_returnsCorrectType() {
        let config = DashboardWidgetConfig(id: .helloWidget, order: 0, isVisible: true)
        let viewModel = EditableWidgetIdentifier.helloWidget.makeViewModel(
            config: config,
            snackBarViewModel: SnackBarViewModel(),
            coursesInteractor: CoursesInteractorLive(env: env)
        )
        XCTAssertTrue(viewModel is HelloWidgetViewModel)
    }

    func test_editableMakeViewModel_coursesAndGroups_returnsCorrectType() {
        let config = DashboardWidgetConfig(id: .coursesAndGroups, order: 0, isVisible: true)
        let viewModel = EditableWidgetIdentifier.coursesAndGroups.makeViewModel(
            config: config,
            snackBarViewModel: SnackBarViewModel(),
            coursesInteractor: CoursesInteractorLive(env: env)
        )
        XCTAssertTrue(viewModel is CoursesAndGroupsWidgetViewModel)
    }

    // MARK: - EditableWidgetIdentifier.makeSubSettingsView

    func test_makeSubSettingsView_helloWidget_returnsNil() {
        XCTAssertNil(EditableWidgetIdentifier.helloWidget.makeSubSettingsView(env: env))
    }

    func test_makeSubSettingsView_coursesAndGroups_returnsView() {
        XCTAssertNotNil(EditableWidgetIdentifier.coursesAndGroups.makeSubSettingsView(env: env))
    }
}
