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

@testable import Core
import Combine
import CombineSchedulers
import CoreData
import XCTest

class CalendarFilterInteractorTests: CoreTestCase {
    private var mockFilterProvider: MockCalendarFilterEntryProvider!
    private var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        super.setUp()
        mockFilterProvider = MockCalendarFilterEntryProvider(context: databaseClient)
        scheduler = DispatchQueue.test
        environment.userDefaults!.reset()
    }

    override func tearDown() {
        environment.userDefaults!.reset()
        super.tearDown()
    }

    func testClearsNoLongerAvailableSelectedContexts() {
        environment.userDefaults!.setCalendarSelectedContexts(
            Set([
                .course("1"),
                .course("2"),
                .group("1"),
                .group("2")
            ]),
            observedStudentId: nil
        )
        mockFilterProvider.mock(contexts: [.course("2"), .group("2")])
        let testee = CalendarFilterInteractorLive(
            observedUserId: nil,
            userDefaults: environment.userDefaults,
            filterProvider: mockFilterProvider,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        // WHEN
        XCTAssertFinish(testee.load(ignoreCache: false))
        scheduler.advance()

        // THEN
        XCTAssertEqual(environment.userDefaults!.calendarSelectedContexts(observedStudentId: nil),
                       Set([
                        .course("2"),
                        .group("2")
                       ]))
    }

    func testUpdatesSelectedContexts() {
        environment.userDefaults!.setCalendarSelectedContexts(
            Set([
                .course("c1")
            ]),
            observedStudentId: nil
        )
        mockFilterProvider.mock(contexts: [.course("c1"), .group("g1")])
        let testee = CalendarFilterInteractorLive(
            observedUserId: nil,
            userDefaults: environment.userDefaults,
            filterProvider: mockFilterProvider,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        // WHEN
        XCTAssertFinish(testee.load(ignoreCache: false))
        scheduler.advance()

        // THEN
        XCTAssertEqual(environment.userDefaults!.calendarSelectedContexts(observedStudentId: nil), Set([.course("c1")]))
        XCTAssertEqual(testee.selectedContexts.value, Set([.course("c1")]))

        // WHEN
        XCTAssertFinish(testee.updateFilteredContexts([]))

        // THEN
        XCTAssertEqual(environment.userDefaults!.calendarSelectedContexts(observedStudentId: nil), Set())
        XCTAssertEqual(testee.selectedContexts.value, Set())
    }

    func testSynchronizesSelectedContextsBetweenDifferentInteractors() {
        mockFilterProvider.mock(contexts: [.course("c1")])
        let testee1 = CalendarFilterInteractorLive(
            observedUserId: nil,
            userDefaults: environment.userDefaults,
            filterProvider: mockFilterProvider,
            scheduler: .immediate
        )
        let testee2 = CalendarFilterInteractorLive(
            observedUserId: nil,
            userDefaults: environment.userDefaults,
            filterProvider: mockFilterProvider,
            scheduler: .immediate
        )
        XCTAssertEqual(testee1.selectedContexts.value, Set())
        XCTAssertEqual(testee2.selectedContexts.value, Set())

        // WHEN
        XCTAssertFinish(testee1.updateFilteredContexts([.course("c1")]))

        // THEN
        XCTAssertEqual(testee1.selectedContexts.value, Set([.course("c1")]))
        XCTAssertEqual(testee2.selectedContexts.value, Set([.course("c1")]))
    }

    func testSelectsContextsUpToLimitOnFirstStart() {
        mockFilterProvider.mock(contexts: [.course("c1"), .course("c2"), .course("c3"), .course("c4"), .course("c5"),
                                           .group("g1"), .group("g2"), .group("g3"), .group("g4"), .group("g5"),
                                           .user("u1")
                                          ])

        // Mock max 10 context filter limit
        let settingsRequest = GetEnvironmentSettingsRequest()
        api.mock(
            settingsRequest,
            value: .init(calendar_contexts_limit: 10, enable_inbox_signature_block: false, disable_inbox_signature_block_for_students: false)
        )

        let testee = CalendarFilterInteractorLive(
            observedUserId: nil,
            userDefaults: environment.userDefaults,
            filterProvider: mockFilterProvider,
            isCalendarFilterLimitEnabled: true,
            scheduler: scheduler.eraseToAnyScheduler()
        )

        // WHEN
        XCTAssertFinish(testee.load(ignoreCache: false))
        scheduler.advance()

        // THEN
        XCTAssertEqual(testee.selectedContexts.value, Set([
            .user("u1"),
            .course("c1"),
            .course("c2"),
            .course("c3"),
            .course("c4"),
            .course("c5"),
            .group("g1"),
            .group("g2"),
            .group("g3"),
            .group("g4")
        ]))
    }
}

class MockCalendarFilterEntryProvider: CalendarFilterEntryProvider {
    private let context: NSManagedObjectContext
    private var filters: [CDCalendarFilterEntry] = []

    init(
        context: NSManagedObjectContext
    ) {
        self.context = context
    }

    func mock(contexts: [Context]) {
        context.delete(filters)
        filters = contexts.map {
            let filter: CDCalendarFilterEntry = context.insert()
            filter.context = $0
            filter.name = "test"
            return filter
        }
    }

    func make(ignoreCache: Bool) -> AnyPublisher<[CDCalendarFilterEntry], Error>? {
        Just(filters)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
