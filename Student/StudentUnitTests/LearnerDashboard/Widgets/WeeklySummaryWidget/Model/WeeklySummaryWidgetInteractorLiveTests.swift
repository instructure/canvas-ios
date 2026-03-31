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
import TestsFoundation
import XCTest
@testable import Student

final class WeeklySummaryWidgetInteractorLiveTests: StudentTestCase {

    private var testee: WeeklySummaryWidgetInteractorLive!
    private var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        testee = WeeklySummaryWidgetInteractorLive(env: env)
    }

    override func tearDown() {
        subscriptions = []
        testee = nil
        super.tearDown()
    }

    // MARK: - clearCache

    func test_clearCache_deletesAllEntries() {
        makeEntry(id: "e1", category: .missing)
        makeEntry(id: "e2", category: .due, weekStart: Clock.now.startOfWeek())
        makeEntry(id: "e3", category: .newGrades, weekStart: Clock.now.startOfWeek())

        XCTAssertFinish(testee.clearCache(), timeout: 5)

        let remaining: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: .all)
        XCTAssertTrue(remaining.isEmpty)
    }

    func test_clearCache_deletesTTLRecords() {
        makeTTL(key: GetMissingWeeklySummaryEntries.cacheKey)
        makeTTL(key: GetWeeklyDueAndGradesEntries.cacheKeyPrefix + "2026-01-01T00:00:00Z")

        XCTAssertFinish(testee.clearCache(), timeout: 5)

        let remaining: [TTL] = databaseClient.fetch(scope: .all)
        XCTAssertTrue(remaining.isEmpty)
    }

    // MARK: - hasCachedSummary

    func test_hasCachedSummary_returnsFalseWhenNoCachedData() {
        let weekStart = Clock.now.startOfWeek()

        XCTAssertFirstValueEquals(testee.hasCachedSummary(weekStart: weekStart), false, timeout: 5)
    }

    func test_hasCachedSummary_returnsTrueWhenBothCachesAreValid() {
        let weekStart = Clock.now.startOfWeek()
        makeValidTTL(key: GetMissingWeeklySummaryEntries.cacheKey)
        makeValidTTL(key: GetWeeklyDueAndGradesEntries.cacheKeyPrefix + weekStart.isoString())

        XCTAssertFirstValueEquals(testee.hasCachedSummary(weekStart: weekStart), true, timeout: 5)
    }

    func test_hasCachedSummary_returnsFalseWhenMissingCacheIsExpired() {
        let weekStart = Clock.now.startOfWeek()
        makeValidTTL(key: GetWeeklyDueAndGradesEntries.cacheKeyPrefix + weekStart.isoString())

        XCTAssertFirstValueEquals(testee.hasCachedSummary(weekStart: weekStart), false, timeout: 5)
    }

    func test_hasCachedSummary_returnsFalseWhenWeeklyCacheIsExpired() {
        let weekStart = Clock.now.startOfWeek()
        makeValidTTL(key: GetMissingWeeklySummaryEntries.cacheKey)

        XCTAssertFirstValueEquals(testee.hasCachedSummary(weekStart: weekStart), false, timeout: 5)
    }

    // MARK: - getSummary

    func test_getSummary_mapsMissingEntriesToFilters() {
        let weekStart = Clock.now.startOfWeek()
        let missing = makeEntry(id: "m1", category: .missing)
        missing.title = "Missing Assignment"
        makeValidTTL(key: GetMissingWeeklySummaryEntries.cacheKey)
        makeValidTTL(key: GetWeeklyDueAndGradesEntries.cacheKeyPrefix + weekStart.isoString())

        XCTAssertFirstValue(testee.getSummary(weekStart: weekStart, ignoreCache: false), timeout: 5) { filters in
            XCTAssertEqual(filters.missing.count, 1)
            XCTAssertEqual(filters.missing.first?.title, "Missing Assignment")
            XCTAssertTrue(filters.due.isEmpty)
            XCTAssertTrue(filters.newGrades.isEmpty)
        }
    }

    func test_getSummary_mapsDueAndNewGradesEntriesToFilters() {
        let weekStart = Clock.now.startOfWeek()
        let due = makeEntry(id: "d1", category: .due, weekStart: weekStart)
        due.title = "Due Assignment"
        let grade = makeEntry(id: "g1", category: .newGrades, weekStart: weekStart)
        grade.title = "Graded Assignment"
        makeValidTTL(key: GetMissingWeeklySummaryEntries.cacheKey)
        makeValidTTL(key: GetWeeklyDueAndGradesEntries.cacheKeyPrefix + weekStart.isoString())

        XCTAssertFirstValue(testee.getSummary(weekStart: weekStart, ignoreCache: false), timeout: 5) { filters in
            XCTAssertTrue(filters.missing.isEmpty)
            XCTAssertEqual(filters.due.count, 1)
            XCTAssertEqual(filters.due.first?.title, "Due Assignment")
            XCTAssertEqual(filters.newGrades.count, 1)
            XCTAssertEqual(filters.newGrades.first?.title, "Graded Assignment")
        }
    }

    // MARK: - Private helpers

    @discardableResult
    private func makeEntry(
        id: String,
        category: CDDashboardWeeklySummaryEntry.Category,
        weekStart: Date = CDDashboardWeeklySummaryEntry.missingWeekStart
    ) -> CDDashboardWeeklySummaryEntry {
        let entry = CDDashboardWeeklySummaryEntry.findOrCreate(weekStart: weekStart, category: category, id: id, in: databaseClient)
        entry.weekStart = weekStart
        entry.category = category
        entry.submissionTypes = []
        return entry
    }

    @discardableResult
    private func makeTTL(key: String) -> TTL {
        let ttl: TTL = databaseClient.insert()
        ttl.key = key
        return ttl
    }

    @discardableResult
    private func makeValidTTL(key: String) -> TTL {
        let ttl = makeTTL(key: key)
        ttl.lastRefresh = Clock.now
        return ttl
    }
}
