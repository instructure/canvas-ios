//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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
import Combine
import XCTest

class CourseSyncConferencesInteractorLiveTests: CoreTestCase {

    override class func tearDown() {
        OfflineModeAssembly.reset()
        super.tearDown()
    }

    func testAssociatedTab() {
        XCTAssertEqual(CourseSyncConferencesInteractorLive().associatedTabType, .conferences)
    }

    func testSavedDataPopulatesViewController() {
        // MARK: - GIVEN
        api.mock(GetCustomColors(), value: .init(custom_colors: [:]))
        api.mock(GetCourse(courseID: "testCourse"), value: .make(id: "testCourse"))
        api.mock(GetConferences(context: .course("testCourse")), value: .init(conferences: [
            .make(context_id: "course_testCourse",
                  description: "this test conference ended",
                  ended_at: .distantPast,
                  id: "1",
                  title: "ended conference"),
            .make(context_id: "course_testCourse",
                  description: "this is an ongoing test conference",
                  id: "2",
                  started_at: Date().addingTimeInterval(-1),
                  title: "ongoing conference"),
        ]))
        XCTAssertFinish(CourseSyncConferencesInteractorLive().getContent(courseId: "testCourse"))
        API.resetMocks()

        // MARK: - WHEN
        OfflineModeAssembly.mock(AlwaysOfflineModeInteractor())
        let testee = ConferenceListViewController.create(context: .course("testCourse"))
        testee.view.layoutIfNeeded()
        testee.viewWillAppear(false)
        drainMainQueue()

        // MARK: - THEN
        XCTAssertEqual(testee.tableView.numberOfSections, 2) // new and concluded conferences sections

        guard let newConferencesHeader = testee.tableView.headerView(forSection: 0) as? SectionHeaderView else {
            return XCTFail()
        }
        XCTAssertEqual(newConferencesHeader.titleLabel.text, "New Conferences")

        guard let concludedSectionHeader = testee.tableView.headerView(forSection: 1) as? SectionHeaderView else {
            return XCTFail()
        }
        XCTAssertEqual(concludedSectionHeader.titleLabel.text, "Concluded Conferences")

        guard let ongoingConferenceCell = testee.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ConferenceListCell else {
            return XCTFail()
        }
        XCTAssertEqual(ongoingConferenceCell.titleLabel.text, "ongoing conference")
        XCTAssertEqual(ongoingConferenceCell.detailsLabel.text, "this is an ongoing test conference")
        XCTAssertEqual(ongoingConferenceCell.statusLabel.text, "In Progress")

        guard let concludedConferenceCell = testee.tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ConferenceListCell else {
            return XCTFail()
        }
        XCTAssertEqual(concludedConferenceCell.titleLabel.text, "ended conference")
        XCTAssertEqual(concludedConferenceCell.detailsLabel.text, "this test conference ended")
        XCTAssertEqual(concludedConferenceCell.statusLabel.text?.hasPrefix("Concluded"), true)
    }
}

class AlwaysOfflineModeInteractor: OfflineModeInteractor {
    func isFeatureFlagEnabled() -> Bool {
        true
    }

    func observeIsFeatureFlagEnabled() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func isOfflineModeEnabled() -> Bool {
        true
    }

    func observeIsOfflineMode() -> AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func observeNetworkStatus() -> AnyPublisher<NetworkAvailabilityStatus, Never> {
        Just(NetworkAvailabilityStatus.disconnected).eraseToAnyPublisher()
    }
}
