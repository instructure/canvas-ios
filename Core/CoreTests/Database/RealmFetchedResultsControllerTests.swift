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
    override func setUp() {
        super.setUp()
        let config = RealmPersistence.testingConfig(inMemoryIdentifier: self.name)
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

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 5)
        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)
    }

    func testSectionsWithNilKeyValue() {
        let _: Course = p.make(["id": "1", "name": "a", "color": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "color": "blue"])
        let _: Course = p.make(["id": "3", "name": "c", "color": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "color": "blue"])
        let _: Course = p.make(["id": "5", "name": "e"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 2),
            ]

        let sort = SortDescriptor(key: "name", ascending: false)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "color")
        try! frc.performFetch()
        let sections = frc.sections!

        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 5)
        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)
    }

    func testObjectAtKeyPathWithSections() {
        let _: Course = p.make(["id": "1", "name": "a", "color": "red"])
        let _: Course = p.make(["id": "2", "name": "b", "color": "blue"])
        let c: Course = p.make(["id": "3", "name": "c", "color": "red"])
        let _: Course = p.make(["id": "4", "name": "d", "color": "blue"])
        let _: Course = p.make(["id": "5", "name": "e"])

        let expected: [FetchedSection] = [
            FetchedSection(name: "blue", numberOfObjects: 2),
            FetchedSection(name: "", numberOfObjects: 1),
            FetchedSection(name: "red", numberOfObjects: 2),
            ]

        let sort = SortDescriptor(key: "name", ascending: true)
        frc = RealmFetchedResultsController<Course>(persistence: p, sortDescriptors: [sort], sectionNameKeyPath: "color")
        try! frc.performFetch()
        let sections = frc.sections!
        let objs = frc.fetchedObjects
        XCTAssertEqual(objs!.count, 5)
        XCTAssertEqual(sections.count, 3)
        XCTAssertEqual(sections, expected)

        let obj = frc.object(at: IndexPath(row: 1, section: 2))
        XCTAssertEqual(obj, c)
    }
}
