//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

private let defaultTTL: TimeInterval = 60 * 60 * 2 // 2 hours

public class TTLOperation: GroupOperation {
    public let database: DatabaseStore
    public var ttl: TimeInterval
    private let operation: Operation
    private let key: String
    private let force: Bool
    private var ttlExpired: Bool?
    private var shouldRefresh: Bool {
        return force || ttlExpired == true
    }
    private var ttlPredicate: NSPredicate {
        return NSPredicate(format: "%K == %@", "key", key)
    }

    init(key: String, database: DatabaseStore, operation: Operation, force: Bool = false, ttl: TimeInterval = defaultTTL) {
        self.key = key
        self.database = database
        self.force = force
        self.ttl = ttl
        self.operation = operation
        super.init()

        addSequence([
            checkTTL(),
            refreshOrNot(operation),
            updateLastRefresh(),
        ])
    }

    func checkTTL() -> Operation {
        return DatabaseOperation(database: database) { [weak self, ttlPredicate, ttl] client in
            guard let cache: TTL = client.fetch(ttlPredicate).first, let lastRefresh = cache.lastRefresh else {
                self?.ttlExpired = true
                return
            }
            self?.ttlExpired = lastRefresh + ttl < Clock.currentTime()
        }
    }

    func refreshOrNot(_ operation: Operation) -> Operation {
        return BlockOperation { [weak self] in
            if self?.shouldRefresh == true, let operation = self?.operation {
                self?.addOperation(operation)
            }
        }
    }

    func updateLastRefresh() -> Operation {
        let now = Clock.currentTime()
        return DatabaseOperation(database: database) { [weak self, ttlPredicate, key] client in
            guard self?.shouldRefresh == true else {
                return
            }
            let cache: TTL = client.fetch(ttlPredicate).first ?? client.insert()
            cache.key = key
            cache.lastRefresh = now
            try client.save()
        }
    }
}
