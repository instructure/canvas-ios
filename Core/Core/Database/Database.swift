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

public protocol DatabaseClient {
    func insert<T>() -> T
    func fetch<T>(_ predicate: NSPredicate) -> [T]
    func delete<T>(_ object: T)
    func fetchedResultsController<T>(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor]?, sectionNameKeyPath: String?) -> FetchedResultsController<T>
    func save() throws
}

extension DatabaseClient {
    public func fetch<T>() -> [T] {
        return fetch(NSPredicate(value: true))
    }
}

public protocol DatabaseStore {
    var mainClient: DatabaseClient { get }
    func perform(block: @escaping (DatabaseClient) -> Void)
    func performBackgroundTask(block: @escaping (DatabaseClient) -> Void)
    func clearAllRecords() throws
}
