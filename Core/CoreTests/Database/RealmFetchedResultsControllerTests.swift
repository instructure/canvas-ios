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

import XCTest
@testable import Core

class RealmFetchedResultsControllerTests: XCTestCase {

    var frc: FetchedResultsController<Course>!
    var p: RealmPersistence!
    var resultsDidChange = false
    var expectation = XCTestExpectation(description: "delegate was called")

    override func setUp() {
        super.setUp()

        let config = RealmPersistence.testingConfig(identifier: self.name)
        p = RealmPersistence(configuration: config)
    }

    func testFetch() {
        let a: Course = p.make(["id": "1", "name": "a"])
        let b: Course = p.make(["id": "2", "name": "b"])

        let expected = [a, b]

        frc = RealmFetchedResultsController<Course>(persistence: p)
        try! frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)
    }

    func testFetchWithAdd() {
        let a: Course = p.make(["id": "1", "name": "a"])
        let b: Course = p.make(["id": "2", "name": "b"])

        let expected = [a, b]

        frc = RealmFetchedResultsController<Course>(persistence: p)
        frc.delegate = self
        try! frc.performFetch()

        var objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)

        var c: Course?
        try? p.perform { (pp) in
            c = Course.make(["id": "3", "name": "c"])
            try pp.addOrUpdate(c)
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(resultsDidChange)
        XCTAssertNoThrow(try frc.performFetch())
        objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 3)
        XCTAssertEqual(objs, [a, b, c!])
    }

    func testObjectAtIndex() {
        _ = p.make(["id": "1", "name": "a"]) as Course
        let b: Course = p.make(["id": "2", "name": "b"])
        let indexPath = IndexPath(item: 1, section: 0)

        frc = RealmFetchedResultsController<Course>(persistence: p)
        try! frc.performFetch()
        let object = frc.object(at: indexPath)

        XCTAssertEqual(object, b)
    }

    func testPredicate() {
        let a: Course = p.make(["id": "1", "name": "foo"])
        let _: Course = p.make(["id": "2", "name": "bar"])
        let c: Course = p.make(["id": "3", "name": "foobar"])
        let expected = [a, c]

        let pred = NSPredicate(format: "name contains[c] %@", "foo")
        let sort = SortDescriptor(key: "name", ascending: true)

        frc = RealmFetchedResultsController<Course>(persistence: p, predicate: pred, sortDescriptors: [sort])
        try! frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 2)
        XCTAssertEqual(objs, expected)
    }

    func testSort() {
        let c: Course = p.make(["id": "3", "name": "c"])
        let a: Course = p.make(["id": "1", "name": "a"])
        let b: Course = p.make(["id": "2", "name": "b"])
        let expected = [c, b, a]

        let sort = SortDescriptor(key: "name", ascending: false)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort])
        try! frc.performFetch()

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 3)
        XCTAssertEqual(objs, expected)
    }

    func testSections() {
        let _: Course = p.make(["id": "1", "name": "a", "color": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "color": "blue"])
        let _: Course = p.make(["id": "3", "name": "c", "color": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "color": "blue"])
        let _: Course = p.make(["id": "5", "name": "e", "color": "green"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "green", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 2),
            ]

        let sort = SortDescriptor(key: "name", ascending: false)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "color")
        try! frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)
    }

    func testSectionsWithNilKeyValue() {
        let _: Course = p.make(["id": "1", "name": "a", "color": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "color": "blue"])
        let _: Course = p.make(["id": "3", "name": "c", "color": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "color": "blue"])
        let e: Course = p.make(["id": "5", "name": "e"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "red", numberOfObjects: 2),
            FetchedSection(name: "", numberOfObjects: 1),
            ]

        let sort = SortDescriptor(key: "name", ascending: false)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "color")
        try! frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)

        let objectAtIndex = frc.object(at: IndexPath(row: 0, section: 2) )
        XCTAssertEqual(objectAtIndex, e)
    }

    func testObjectAtKeyPathWithSections() {
        let _: Course = p.make(["id": "1", "name": "a", "color": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "color": "blue"])
        let c: Course = p.make(["id": "3", "name": "c", "color": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "color": "blue"])
        let e: Course = p.make(["id": "5", "name": "e"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "red", numberOfObjects: 2),
            FetchedSection(name: "", numberOfObjects: 1),
            ]

        let sort = SortDescriptor(key: "name", ascending: true)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "color")
        try! frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)

        var objectAtIndex = frc.object(at: IndexPath(row: 0, section: 2))
        XCTAssertEqual(objectAtIndex, e)

        objectAtIndex = frc.object(at: IndexPath(row: 1, section: 1))
        XCTAssertEqual(objectAtIndex, c)
    }

    func testObservingValueChangesInSections() {
        let a: Course = p.make(["id": "1", "name": "a", "color": "red"])
        let b: Course = p.make(["id": "2", "name": "b", "color": "blue"])

        var expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 1),
            ]

        let sort = SortDescriptor(key: "name", ascending: true)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "color")
        try! frc.performFetch()
        var sections = frc.sections!

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections, expected)

        let obj = frc.object(at: IndexPath(row: 0, section: 1))
        XCTAssertEqual(obj, a)

        frc.delegate = self

        try! p.perform { (_) in
            b.color = "red"
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(resultsDidChange)
        XCTAssertNoThrow(try frc.performFetch())
        sections = frc.sections!

        expected = [
            FetchedSection(name: "red", numberOfObjects: 2),
            ]

        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections, expected)
    }

    func testSortingOfSectionsWithDates() {

        let mockNow = Date(timeIntervalSince1970: 1536597712.04575)
        let mock100DaysFromMockNow = Calendar.current.date(byAdding: .day, value: 100, to: Date(timeIntervalSince1970: 1545241312.0443602))
        let _: TTL = p.make(["key": "a", "lastRefresh": mockNow])
        let _: TTL = p.make(["key": "b", "lastRefresh": mock100DaysFromMockNow])

        let expected: [FetchedSection] = [
            FetchedSection(name: "2018-09-10 16:41:52 +0000", numberOfObjects: 1),
            FetchedSection(name: "2019-03-29 16:41:52 +0000", numberOfObjects: 1),
            ]

        let sort = SortDescriptor(key: "key", ascending: true)
        let frc: FetchedResultsController<TTL> = RealmFetchedResultsController<TTL>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "lastRefresh")
        try! frc.performFetch()
        let sections = frc.sections!

        XCTAssertEqual(sections.count, 2)
        XCTAssertEqual(sections, expected)
    }

    func testAssertionWhenNoKeyPathExists() {
        let _: Course = p.make(["id": "1", "name": "a", "color": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "color": "blue"])

        let sort = SortDescriptor(key: "name", ascending: true)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "fooooobar")
        do {
            try frc.performFetch()
            XCTFail("should have thrown an error")
        } catch {
            XCTAssertEqual(error as! PersistenceError, PersistenceError.invalidSectionNameKeyPath)
        }
    }

    func testObservingValueChangesInRowsOnBackgroundThread() {
        let _: Course = p.make(["id": "1", "name": "a"])
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: nil, sectionNameKeyPath: nil)
        frc.delegate = self
        try! frc.performFetch()
        XCTAssertEqual(frc.fetchedObjects?.count, 1)

        let opExpectation = XCTestExpectation(description: "opExpectation")
        let op = BlockOperation {
            RealmPersistence.performBackgroundTask(block: { (pp) in
                let b: Course = Course.make(["id": "2", "name": "b", "color": "blue"])
                try pp.addOrUpdate(b)
                let courses: [Course] = pp.fetch()
                XCTAssertEqual(courses.count, 2)
            }, completionHandler: {
                opExpectation.fulfill()
            })
        }

        let q = OperationQueue()
        q.addOperation(op)

        wait(for: [opExpectation], timeout: 0.1)

        p.refresh()
        try! frc.performFetch()
        let objs = frc.fetchedObjects ?? []
        XCTAssertEqual(objs.count, 2)
    }
}

extension RealmFetchedResultsControllerTests: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        resultsDidChange = true
        expectation.fulfill()
    }

}
