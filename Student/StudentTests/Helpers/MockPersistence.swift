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
@testable import Core

class MockFetchedResultsController<T>: FetchedResultsController<T> {

    var error: NSError?
    var mockObjects: [T]?
    var sortDescriptors: [SortDescriptor]?
    var predicate: NSPredicate?
    var sectionNameKeyPath: String?

    init(persistence: RealmPersistence = RealmPersistence(configuration: RealmPersistence.config),
         predicate: NSPredicate? = nil,
         sortDescriptors: [SortDescriptor]? = nil,
         sectionNameKeyPath: String? = nil) {
        super.init()

        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.sectionNameKeyPath = sectionNameKeyPath
    }

    public override var fetchedObjects: [T]? {
        return mockObjects
    }

    public override func performFetch() throws {
        if let error = error {
            throw error
        }
    }
}

class MockPersistence: Persistence {

    func fetch<T>(predicate: NSPredicate?, sortDescriptors: [SortDescriptor]?) -> [T] {
        fatalError("Not Implemented")
    }

    func insert<T>() -> T {
        fatalError("Not Implemented")
    }

    func delete<T>(_ entity: T) throws {
        fatalError("Not Implemented")
    }

    func fetchedResultsController<T>(predicate: NSPredicate, sortDescriptors: [SortDescriptor]?, sectionNameKeyPath: String?) -> FetchedResultsController<T> {
        let frc: MockFetchedResultsController<T> = MockFetchedResultsController(predicate: predicate, sortDescriptors: sortDescriptors, sectionNameKeyPath: sectionNameKeyPath)
        return frc
    }

    func addOrUpdate<T>(_ entity: T) throws {
        fatalError("Not Implemented")
    }

    func addOrUpdate<T>(_ entities: [T]) throws {
        fatalError("Not Implemented")
    }

    func perform(block: @escaping PersistenceBlockHandler) throws {
        fatalError("Not Implemented")
    }

    static func performBackgroundTask(block: @escaping PersistenceBlockHandler) {
        fatalError("Not Implemented")
    }

    func clearAllRecords() throws {
        fatalError("Not Implemented")
    }

    func refresh() {
        fatalError("Not Implemented")
    }
}
