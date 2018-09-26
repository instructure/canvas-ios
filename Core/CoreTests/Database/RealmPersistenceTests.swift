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
import RealmSwift
@testable import Core

class RealmPersistenceTests: XCTestCase {
    var p: RealmPersistence! = nil
    var config: Realm.Configuration!
    var frcExpectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        frcExpectation = XCTestExpectation(description: "frc expectation")
        config = RealmPersistence.testingConfig(identifier: self.name)
        p = RealmPersistence(configuration: config)
        assertNoCourseObjectsPreExisting()
    }

    func testInsertOfExistingObject() {
        let a: Course = p.insert()
        a.name = "foo"
        a.id = "1"

        try? p.addOrUpdate(a)
        var objs: [Course] = p.fetch()
        XCTAssertEqual(objs.count, 1)

        let b: Course = p.insert()
        b.name = "bar"
        b.id = "1"

        do {
            try p.addOrUpdate(b)
        } catch {
            print(error)
        }

        objs = p.fetch()
        XCTAssertEqual(objs.count, 1)
        XCTAssertEqual(objs.first?.name, "bar")
    }

    func testUpdateMany() {
        let a = Course(value: ["id": "1", "name": "a"])
        let b = Course(value: ["id": "2", "name": "b"])

        try? p.addOrUpdate([a, b])

        let aa: Course = Course(value: a)
        aa.name = "aa"
        let bb = Course(value: ["id": "2", "name": "bb"])
        try? p.addOrUpdate([aa, bb])

        let objs: [Course] = p.fetch()
        XCTAssertEqual(objs.first?.name, "aa")
        XCTAssertEqual(objs.last?.name, "bb")
        XCTAssertEqual(objs.count, 2)
    }

    func testDelete() {
        let a = Course(value: ["id": "1", "name": "a"])
        try? p.addOrUpdate(a)

        var objs: [Course] = p.fetch()
        XCTAssertEqual(objs.count, 1)

        try? p.delete(a)

        objs = p.fetch()
        XCTAssertEqual(objs.count, 0)
    }

    func testInsert() {
        let name = "test object"

        let model: Course = p.insert()
        model.name = name
        model.id = "1"
        try? p.addOrUpdate(model)

        let objs: [Course] = p.fetch()
        XCTAssertEqual(objs.count, 1)
        XCTAssertEqual(objs.first?.name, name)
    }

    func testPerformSaveOnBackground() {
        let model = Course(value: ["id": "5", "name": "n"])
        try? p.addOrUpdate(model)

        let expectation = XCTestExpectation(description: "expectation")
        let op = BlockOperation {
        RealmPersistence.performBackgroundTask(block: { [weak self] (persistence) in
            let a = self!.p!
            let b = persistence as! RealmPersistence
            XCTAssertFalse(a.store === b.store)

            let model = Course(value: ["id": "1", "name": "a"])

            XCTAssertNoThrow(try persistence.addOrUpdate(model))
            }, completionHandler: {
        })
        }

        let q = OperationQueue()
        op.completionBlock = { expectation.fulfill() }
        q.addOperation(op)

        wait(for: [expectation], timeout: 1)

        p.refresh()
        let models: [Course] = p.fetch()

        XCTAssertEqual(models.count, 2)
    }

    func testPerformSaveOnBackgroundWithExistingObject() {
        let model = Course(value: ["id": "1", "name": "a"])
        try? p.addOrUpdate(model)
        let expectedName = "updated"

        let expectation = XCTestExpectation(description: "expectation")
        let op = BlockOperation {
            RealmPersistence.performBackgroundTask(block: { [weak self] (persistence) in
                let a = self!.p!
                let b = persistence as! RealmPersistence
                XCTAssertFalse(a.store === b.store)

                let objs: [Course] = persistence.fetch(predicate: nil, sortDescriptors: nil)
                XCTAssertEqual(objs.count, 1)

                let model: Course = objs.first!
                model.name = expectedName

                }, completionHandler: {
            })
        }

        let q = OperationQueue()
        op.completionBlock = { expectation.fulfill() }
        q.addOperation(op)

        wait(for: [expectation], timeout: 0.3)
        p.refresh()
        let models: [Course] = p.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first!.name, expectedName)
    }

    func testPerformBlock() {
        let model = Course(value: ["id": "1", "name": "a"])
        try? p.addOrUpdate(model)
        let expectedName = "updated"

        let expectation = XCTestExpectation(description: "expectation")
        try? p.perform { (persistence) in

            let a = self.p!
            let b = persistence as! RealmPersistence
            XCTAssertTrue(a.store === b.store)

            var objs: [Course]!
            if let persistence = persistence as? RealmPersistence {
                objs = persistence.fetch(predicate: nil, sortDescriptors: nil)
                XCTAssertEqual(objs.count, 1)
            } else {
                XCTFail()
            }

            let model: Course = objs.first!

            model.name = expectedName
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        let models: [Course] = p.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first!.name, expectedName)
    }

    func testFetchWithMoreThanOneObject() {
        let a = Course(value: ["id": "1", "name": "a"])
        let b = Course(value: ["id": "2", "name": "b"])

        try? p.addOrUpdate([a, b])

        let objs: [Course] = p.fetch()
        XCTAssertEqual(objs.count, 2)

        var models: [Course] = p.fetch()

        XCTAssertEqual(models.count, 2)

        models = p.fetch(predicate: nil, sortDescriptors: nil)

        XCTAssertEqual(models.count, 2)
    }

    func testFetchWithPredicate() {
        let a = Course(value: ["id": "1", "name": "a"])
        let b = Course(value: ["id": "2", "name": "b"])

        try? p.addOrUpdate([a, b])

        let objs: [Course] = p.fetch()
        XCTAssertEqual(objs.count, 2)

        let pred = NSPredicate(format: "id == %@", "1")

        let models: [Course] = p.fetch(predicate: pred, sortDescriptors: nil)

        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first?.name, "a")
    }

    func testFetchWithSortDescriptors() {
        let a = Course(value: ["id": "1", "name": "a"])
        let b = Course(value: ["id": "2", "name": "b"])
        let c = Course(value: ["id": "3", "name": "c"])

        try? p.addOrUpdate([a, c, b])

        let models: [Course] = p.fetch(predicate: nil, sortDescriptors: [SortDescriptor(key: "name", ascending: false)])
            XCTAssertEqual(models.count, 3)
            XCTAssertEqual(models.first?.name, "c")
            XCTAssertEqual(models.last?.name, "a")

    }

    func testFetchedResultsController() {
        //  given
        let a: Course = p.make(["id": "1", "name": "foo"])
        let _: Course = p.make(["id": "2", "name": "bar"])
        let c: Course = p.make(["id": "3", "name": "foobar"])
        let expected = [a, c]

        let pred = NSPredicate(format: "name contains[c] %@", "foo")
        let sort = [SortDescriptor(key: "name", ascending: true)]

        //  when
        let frc = p.fetchedResultsController(predicate: pred, sortDescriptors: sort, sectionNameKeyPath: nil) as FetchedResultsController<Course>
        try! frc.performFetch()
        let objs = frc.fetchedObjects

        //  then
        XCTAssertEqual(objs, expected)
    }

    func assertNoCourseObjectsPreExisting() {
        let objs: [Course] = p.fetch()
        XCTAssertEqual(objs.count, 0)
    }

}

extension RealmPersistenceTests: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        frcExpectation.fulfill()
    }
}
