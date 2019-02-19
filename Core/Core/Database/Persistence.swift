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

public typealias PersistenceBlockHandler = (PersistenceClient) -> Void

public protocol Persistence {
    var mainClient: PersistenceClient { get }
    func perform(block: @escaping PersistenceBlockHandler)
    func performBackgroundTask(block: @escaping PersistenceBlockHandler)
    func fetchedResultsController<T>(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String?) -> FetchedResultsController<T>
    func clearAllRecords() throws
}

public protocol PersistenceClient {
    func insert<T>() -> T
    func fetch<T>(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T]
    func delete<T>(_ entity: T) throws
    func save() throws
    func refresh()
}

extension Persistence {
    func fetchedResultsController<T>(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor], sectionNameKeyPath: String? = nil) -> FetchedResultsController<T> {
        return fetchedResultsController(predicate: predicate ?? .all, sortDescriptors: sortDescriptors, sectionNameKeyPath: sectionNameKeyPath)
    }
}

extension PersistenceClient {
    public func fetch<T>() -> [T] {
        return self.fetch(predicate: nil, sortDescriptors: nil)
    }

    func fetch<T>(_ predicate: NSPredicate?) -> [T] {
        return self.fetch(predicate: predicate, sortDescriptors: nil)
    }
}

public enum PersistenceError: Error, CustomStringConvertible {
    case wrongEntityType
    case uninitializedPersistence
    case failureToInit
    case invalidSectionNameKeyPath

    public var description: String {
        switch self {
        case .wrongEntityType:
            return "Wrong entity type"
        case .uninitializedPersistence:
            return "Persistence uninitialized"
        case .failureToInit:
            return "Failed to init Persistence"
        case .invalidSectionNameKeyPath:
            return "Invalid section name key path"
        }
    }
}
