//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import CoreData
import XCTest
@testable import Core
import TestsFoundation

class FetchedResultsControllerTests: CoreTestCase {

    var frc: FetchedResultsController<Course>!
    var p: PersistenceClient {
        return databaseClient
    }
    var resultsDidChange = false
    var expectation = XCTestExpectation(description: "delegate was called")

    func testFetch() {
        let a = Course.make(from: .make(id: "1", name: "a"))
        let b = Course.make(from: .make(id: "2", name: "b"))

        let expected = [a, b]

        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)
    }

    func testFetchWithAdd() {
        let a = Course.make(from: .make(id: "1", name: "a"))
        let b = Course.make(from: .make(id: "2", name: "b"))

        let expected = [a, b]

        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.delegate = self
        frc.performFetch()

        var objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)

        var c: Course?
        database.perform { (_) in
            c = Course.make(from: .make(id: "3", name: "c"))
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(resultsDidChange)
        frc.performFetch()
        objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 3)
        XCTAssertEqual(objs, [a, b, c!])
    }

    func testObjectAtIndex() {
        Course.make(from: .make(id: "1", name: "a"))
        let b = Course.make(from: .make(id: "2", name: "b"))
        let indexPath = IndexPath(item: 1, section: 0)

        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.performFetch()
        let object = frc.object(at: indexPath)

        XCTAssertEqual(object, b)
    }

    func testPredicate() {
        let a = Course.make(from: .make(id: "1", name: "foo"))
        Course.make(from: .make(id: "2", name: "bar"))
        let c = Course.make(from: .make(id: "3", name: "foobar"))
        let expected = [a, c]

        let pred = NSPredicate(format: "name contains[c] %@", "foo")
        let sort = NSSortDescriptor(key: "name", ascending: true)

        frc = database.fetchedResultsController(predicate: pred, sortDescriptors: [sort])
        frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)
    }

    func testSort() {
        let c = Course.make(from: .make(id: "3", name: "c"))
        let a = Course.make(from: .make(id: "1", name: "a"))
        let b = Course.make(from: .make(id: "2", name: "b"))
        let expected = [c, b, a]

        let sort = NSSortDescriptor(key: "name", ascending: false)
        frc = database.fetchedResultsController(sortDescriptors: [sort])
        frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 3)
        XCTAssertEqual(objs, expected)
    }

    func testSections() {
        Course.make(from: .make(id: "1", name: "a", course_code: "red"))
        Course.make(from: .make(id: "2", name: "b", course_code: "blue"))
        Course.make(from: .make(id: "3", name: "c", course_code: "red"))
        Course.make(from: .make(id: "4", name: "d", course_code: "blue"))
        Course.make(from: .make(id: "5", name: "e", course_code: "green"))

        let expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "green", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        let sort = NSSortDescriptor(key: "courseCode", ascending: true)
        let name = NSSortDescriptor(key: "name", ascending: false)
        frc = database.fetchedResultsController(sortDescriptors: [sort, name], sectionNameKeyPath: "courseCode")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)
    }

    func testSectionsWithNilKeyValue() {
        Course.make(from: .make(id: "1", name: "a", course_code: "red"))
        Course.make(from: .make(id: "2", name: "b", course_code: "blue"))
        Course.make(from: .make(id: "3", name: "c", course_code: "red"))
        Course.make(from: .make(id: "4", name: "d", course_code: "blue"))
        let e = Course.make(from: .make(id: "5", name: "e"))

        let expected: [FetchedSection] = [
            FetchedSection(name: "", numberOfObjects: 1),
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        let sort = NSSortDescriptor(key: "courseCode", ascending: true)
        let name = NSSortDescriptor(key: "name", ascending: false)
        frc = database.fetchedResultsController(sortDescriptors: [sort, name], sectionNameKeyPath: "courseCode")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)

        let objectAtIndex = frc.object(at: IndexPath(row: 0, section: 0) )
        XCTAssertEqual(objectAtIndex, e)
    }

    func testObjectAtKeyPathWithSections() {
        Course.make(from: .make(id: "1", name: "a", course_code: "red"))
        Course.make(from: .make(id: "2", name: "b", course_code: "blue"))
        let c = Course.make(from: .make(id: "3", name: "c", course_code: "red"))
        Course.make(from: .make(id: "4", name: "d", course_code: "blue"))
        let e = Course.make(from: .make(id: "5", name: "e"))

        let expected: [FetchedSection] = [
            FetchedSection(name: "", numberOfObjects: 1),
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        let sort = NSSortDescriptor(key: "courseCode", ascending: true)
        let name = NSSortDescriptor(key: "name", ascending: true)
        frc = database.fetchedResultsController(sortDescriptors: [sort, name], sectionNameKeyPath: "courseCode")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)

        var objectAtIndex = frc.object(at: IndexPath(row: 0, section: 0))
        XCTAssertEqual(objectAtIndex, e)

        objectAtIndex = frc.object(at: IndexPath(row: 1, section: 2))
        XCTAssertEqual(objectAtIndex, c)
    }

    func testObservingValueChangesInSections() {
        let a = Course.make(from: .make(id: "1", name: "a", course_code: "red"))
        let b = Course.make(from: .make(id: "2", name: "b", course_code: "blue"))

        var expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 1),
        ]

        let sort = [NSSortDescriptor(key: "courseCode", ascending: true), NSSortDescriptor(key: "name", ascending: true)]
        frc = database.fetchedResultsController(sortDescriptors: sort, sectionNameKeyPath: "courseCode")
        frc.performFetch()
        var sections = frc.sections!

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections, expected)

        let obj = frc.object(at: IndexPath(row: 0, section: 1))
        XCTAssertEqual(obj, a)

        frc.delegate = self

        database.perform { (_) in
            b.courseCode = "red"
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(resultsDidChange)
        frc.performFetch()
        sections = frc.sections!

        expected = [
            FetchedSection(name: "red", numberOfObjects: 2),
        ]

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections, expected)
    }

    func testSortingOfSectionsWithDates() {
        let first = Date(fromISOString: "2019-09-09T00:00:00Z")!
        let second = Date(fromISOString: "2019-09-10T00:00:00Z")!
        TTL.make(key: "a", lastRefresh: first)
        TTL.make(key: "b", lastRefresh: second)

        let expected: [FetchedSection] = [
            FetchedSection(name: "2019-09-09 00:00:00 +0000", numberOfObjects: 1),
            FetchedSection(name: "2019-09-10 00:00:00 +0000", numberOfObjects: 1),
        ]

        let sort = [NSSortDescriptor(key: "key", ascending: true), NSSortDescriptor(key: "lastRefresh", ascending: true)]
        let frc: FetchedResultsController<TTL> = database.fetchedResultsController(sortDescriptors: sort, sectionNameKeyPath: "lastRefresh")
        frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections, expected)
    }

    func testObservingValueChangesInRowsOnBackgroundThread() {
        Course.make(from: .make(id: "1", name: "a"))
        frc = database.fetchedResultsController(sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)])
        frc.delegate = self
        frc.performFetch()
        XCTAssertEqual(frc.fetchedObjects?.count, 1)

        let opExpectation = XCTestExpectation(description: "opExpectation")
        let op = BlockOperation {
            self.database.performBackgroundTask { client in
                Course.make(from: .make(id: "2", name: "b", course_code: "blue"), in: client as! NSManagedObjectContext)
                let courses: [Course] = client.fetch()
                XCTAssertEqual(courses.count, 2)
                opExpectation.fulfill()
            }
        }

        let q = OperationQueue()
        q.addOperation(op)

        wait(for: [opExpectation], timeout: 0.1)

        p.refresh()
        frc.performFetch()
        let objs = frc.fetchedObjects ?? []
        XCTAssertEqual(objs.count, 2)
    }
}

extension FetchedResultsControllerTests: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        resultsDidChange = true
        expectation.fulfill()
    }

}
