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
@testable import Core
@testable import Student
@testable import TestsFoundation
import XCTest

final class GlobalAnnouncementsWidgetInteractorTests: StudentTestCase {

    private static let testData = (
        id1: "announcement1",
        subject1: "some subject1",
        message1: "some message1",
        date1: Date.make(year: 2025, month: 9, day: 15),
        id2: "announcement2",
        subject2: "some subject2",
        message2: "some message2",
        date2: Date.make(year: 2025, month: 9, day: 20)
    )
    private lazy var testData = Self.testData

    private var testee: GlobalAnnouncementsWidgetInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        testee = .init(env: env)
    }

    override func tearDown() {
        testee = nil
        subscriptions.removeAll()
        super.tearDown()
    }

    // MARK: - loadAnnouncements

    func test_loadAnnouncements_shouldFetchFromAPI() {
        api.mock(GetAccountNotificationsRequest(), value: [])

        XCTAssertFinish(testee.loadAnnouncements(ignoreCache: true))
    }

    func test_loadAnnouncements_onFailure_shouldPropagateFailure() {
        api.mock(GetAccountNotificationsRequest(), error: MockError())

        XCTAssertFailure(testee.loadAnnouncements(ignoreCache: true))
    }

    // MARK: - observeAnnouncements

    func test_observeAnnouncements_shouldReturnMappedItems() {
        AccountNotification.save(
            .make(
                icon: .warning,
                id: ID(testData.id1),
                message: testData.message1,
                start_at: testData.date1,
                subject: testData.subject1,
                closed: false
            ),
            in: databaseClient
        )
        AccountNotification.save(
            .make(
                icon: .calendar,
                id: ID(testData.id2),
                message: testData.message2,
                start_at: testData.date2,
                subject: testData.subject2,
                closed: false
            ),
            in: databaseClient
        )

        XCTAssertSingleOutput(testee.observeAnnouncements()) {
            let items = $0.sorted(by: \.id)
            XCTAssertEqual(items.count, 2)

            XCTAssertEqual(items.first?.id, self.testData.id1)
            XCTAssertEqual(items.first?.title, self.testData.subject1)
            XCTAssertEqual(items.first?.message, self.testData.message1)
            XCTAssertEqual(items.first?.startDate, self.testData.date1)
            XCTAssertEqual(items.first?.icon, .warning)

            XCTAssertEqual(items.last?.id, self.testData.id2)
            XCTAssertEqual(items.last?.title, self.testData.subject2)
            XCTAssertEqual(items.last?.message, self.testData.message2)
            XCTAssertEqual(items.last?.startDate, self.testData.date2)
            XCTAssertEqual(items.last?.icon, .calendar)
        }
    }

    func test_observeAnnouncements_shouldFilterOutClosedAnnouncements() {
        AccountNotification.save(
            .make(id: ID(testData.id1), closed: true),
            in: databaseClient
        )
        AccountNotification.save(
            .make(id: ID(testData.id2), closed: false),
            in: databaseClient
        )

        XCTAssertSingleOutput(testee.observeAnnouncements()) { items in
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first?.id, self.testData.id2)
        }
    }

    // MARK: - deleteAnnouncement

    func test_deleteAnnouncement_shouldDeleteAnnuncementFromDatabase() {
        AccountNotification.save(
            .make(id: ID(testData.id1), closed: false),
            in: databaseClient
        )
        let savedItem: AccountNotification? = databaseClient.first(where: \.id, equals: testData.id1)
        XCTAssertNotNil(savedItem)

        XCTAssertFinish(testee.deleteAnnouncement(id: testData.id1))

        let deletedItem: AccountNotification? = databaseClient.first(where: \.id, equals: testData.id1)
        XCTAssertNil(deletedItem)
    }
}
