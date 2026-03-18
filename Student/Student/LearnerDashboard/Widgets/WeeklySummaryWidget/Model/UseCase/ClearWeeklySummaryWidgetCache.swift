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
import CoreData

struct ClearWeeklySummaryWidgetCache: UseCase {
    typealias Model = CDDashboardWeeklySummaryEntry
    typealias Response = Int

    let cacheKey: String? = nil
    /// We don't really want to fetch anything here.
    var scope: Scope { Scope(predicate: NSPredicate(value: false), order: []) }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping RequestCallback) {
        completionHandler(1, nil, nil)
    }

    func reset(context: NSManagedObjectContext) {
        let entries: [CDDashboardWeeklySummaryEntry] = context.fetch(scope: .all)
        context.delete(entries)

        let ttlScope = Scope(
            predicate: NSCompoundPredicate.or(
                NSPredicate(format: "%K BEGINSWITH %@", #keyPath(TTL.key), GetWeeklyDueAndGradesEntries.cacheKeyPrefix),
                NSPredicate(format: "%K == %@", #keyPath(TTL.key), GetMissingWeeklySummaryEntries.cacheKey)
            ),
            order: []
        )
        let cacheKeys: [TTL] = context.fetch(scope: ttlScope)
        context.delete(cacheKeys)
    }

    func write(response: Int?, urlResponse: URLResponse?, to context: NSManagedObjectContext) {}
}
