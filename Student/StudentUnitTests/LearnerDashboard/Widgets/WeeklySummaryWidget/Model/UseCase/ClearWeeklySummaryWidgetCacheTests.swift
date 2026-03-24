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
import XCTest
@testable import Student

final class ClearWeeklySummaryWidgetCacheTests: StudentTestCase {

    private let testee = ClearWeeklySummaryWidgetCache()

    // MARK: - reset

    func test_reset_deletesAllWeeklySummaryEntries() {
        makeEntry(id: "e1", category: .missing)
        makeEntry(id: "e2", category: .due)
        makeEntry(id: "e3", category: .newGrades)

        testee.reset(context: databaseClient)

        let remaining: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: .all)
        XCTAssertTrue(remaining.isEmpty)
    }

    func test_reset_deletesTTLForMissingEntriesKey() {
        makeTTL(key: GetMissingWeeklySummaryEntries.cacheKey)

        testee.reset(context: databaseClient)

        let remaining: [TTL] = databaseClient.fetch(scope: .all)
        XCTAssertFalse(remaining.contains(where: { $0.key == GetMissingWeeklySummaryEntries.cacheKey }))
    }

    func test_reset_deletesTTLForWeeklyEntriesKeys() {
        let key1 = GetWeeklyDueAndGradesEntries.cacheKeyPrefix + "2026-01-06T00:00:00Z"
        let key2 = GetWeeklyDueAndGradesEntries.cacheKeyPrefix + "2026-01-13T00:00:00Z"
        makeTTL(key: key1)
        makeTTL(key: key2)

        testee.reset(context: databaseClient)

        let remaining: [TTL] = databaseClient.fetch(scope: .all)
        XCTAssertFalse(remaining.contains(where: { $0.key == key1 }))
        XCTAssertFalse(remaining.contains(where: { $0.key == key2 }))
    }

    func test_reset_doesNotDeleteUnrelatedTTLKeys() {
        makeTTL(key: "unrelated-cache-key")
        makeTTL(key: "other-feature/data")

        testee.reset(context: databaseClient)

        let remaining: [TTL] = databaseClient.fetch(scope: .all)
        XCTAssertTrue(remaining.contains(where: { $0.key == "unrelated-cache-key" }))
        XCTAssertTrue(remaining.contains(where: { $0.key == "other-feature/data" }))
    }

    func test_reset_isNoOpWhenNothingToDelete() {
        XCTAssertNoThrow(testee.reset(context: databaseClient))
    }

    // MARK: - scope

    func test_scope_neverMatchesAnyEntry() {
        makeEntry(id: "e1", category: .missing)

        let fetched: [CDDashboardWeeklySummaryEntry] = databaseClient.fetch(scope: testee.scope)
        XCTAssertTrue(fetched.isEmpty)
    }

    // MARK: - Private helpers

    @discardableResult
    private func makeEntry(id: String, category: CDDashboardWeeklySummaryEntry.Category) -> CDDashboardWeeklySummaryEntry {
        CDDashboardWeeklySummaryEntry.findOrCreate(weekStart: .distantPast, category: category, id: id, in: databaseClient)
    }

    @discardableResult
    private func makeTTL(key: String) -> TTL {
        let ttl: TTL = databaseClient.insert()
        ttl.key = key
        return ttl
    }
}
