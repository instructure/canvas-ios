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

import XCTest
@testable import Core
import TestsFoundation

class PersistenceTests: CoreTestCase {
    var frcExpectation: XCTestExpectation!
    var client: PersistenceClient {
        return databaseClient
    }

    override func setUp() {
        super.setUp()
        frcExpectation = XCTestExpectation(description: "frc expectation")
        assertNoCourseObjectsPreExisting()
    }

    func testInsertOfExistingObject() {
        let a: Course = client.insert()
        a.name = "foo"
        a.id = "1"

        var objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 1)

        let b: Course = client.fetch(NSPredicate(format: "%K == %@", #keyPath(Course.id), "1")).first ?? client.insert()
        b.name = "bar"
        b.id = "1"

        objs = client.fetch()
        XCTAssertEqual(objs.count, 1)
        XCTAssertEqual(objs.first?.name, "bar")
    }

    func testUpdateMany() {
        Course.make(["id": "1", "name": "a"])
        Course.make(["id": "2", "name": "b"])

        let aa: Course = Course.make(["id": "1"])
        aa.name = "aa"
        Course.make(["id": "2", "name": "bb"])

        let objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 4)
    }

    func testDelete() {
        let a = Course.make(["id": "1", "name": "a"])

        var objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 1)

        try? client.delete(a)

        objs = client.fetch()
        XCTAssertEqual(objs.count, 0)
    }

    func testDeleteCollection() {
        let a = Course.make(["id": "1", "name": "a"])
        let b = Course.make(["id": "2", "name": "b"])

        var objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 2)

        try? client.delete([a, b])

        objs = client.fetch()
        XCTAssertEqual(objs.count, 0)
    }

    func testInsert() {
        let name = "test object"

        let model: Course = client.insert()
        model.name = name
        model.id = "1"

        let objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 1)
        XCTAssertEqual(objs.first?.name, name)
    }

    func testPerformSaveOnBackground() {
        Course.make(["id": "5", "name": "n"])

        let expectation = XCTestExpectation(description: "expectation")
        self.database.performBackgroundTask { client in
            Course.make(["id": "1", "name": "a"], client: client)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        client.refresh()
        let models: [Course] = client.fetch()

        XCTAssertEqual(models.count, 2)
    }

    func testPerformSaveOnBackgroundWithExistingObject() {
        Course.make(["id": "1", "name": "a"])
        let expectedName = "updated"

        let expectation = XCTestExpectation(description: "expectation")
        let op = BlockOperation {
            self.database.performBackgroundTask { (persistence) in
                let objs: [Course] = persistence.fetch(predicate: nil, sortDescriptors: nil)
                XCTAssertEqual(objs.count, 1)

                let model: Course = objs.first!
                model.name = expectedName
                try! persistence.save()
                expectation.fulfill()
            }
        }

        let q = OperationQueue()
        q.addOperation(op)
        wait(for: [expectation], timeout: 0.3)
        client.refresh()
        let models: [Course] = client.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first!.name, expectedName)
    }

    func testPerformBlock() {
        Course.make(["id": "1", "name": "a"])
        let expectedName = "updated"

        let expectation = XCTestExpectation(description: "expectation")
        database.perform { (persistence) in
            var objs: [Course]!
            objs = persistence.fetch(predicate: nil, sortDescriptors: nil)
            XCTAssertEqual(objs.count, 1)

            let model: Course = objs.first!

            model.name = expectedName
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        let models: [Course] = client.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first!.name, expectedName)
    }

    func testFetchWithMoreThanOneObject() {
        Course.make(["id": "1", "name": "a"])
        Course.make(["id": "2", "name": "b"])

        let objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 2)

        var models: [Course] = client.fetch()

        XCTAssertEqual(models.count, 2)

        models = client.fetch(predicate: nil, sortDescriptors: nil)

        XCTAssertEqual(models.count, 2)
    }

    func testFetchWithPredicate() {
        Course.make(["id": "1", "name": "a"])
        Course.make(["id": "2", "name": "b"])

        let objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 2)

        let pred = NSPredicate(format: "id == %@", "1")

        let models: [Course] = client.fetch(predicate: pred, sortDescriptors: nil)

        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models.first?.name, "a")
    }

    func testFetchWithSortDescriptors() {
        Course.make(["id": "1", "name": "a"])
        Course.make(["id": "2", "name": "b"])
        Course.make(["id": "3", "name": "c"])

        let models: [Course] = client.fetch(predicate: nil, sortDescriptors: [NSSortDescriptor(key: "name", ascending: false)])
            XCTAssertEqual(models.count, 3)
            XCTAssertEqual(models.first?.name, "c")
            XCTAssertEqual(models.last?.name, "a")

    }

    func testFetchedResultsController() {
        //  given
        let a: Course = client.make(["id": "1", "name": "foo"])
        let _: Course = client.make(["id": "2", "name": "bar"])
        let c: Course = client.make(["id": "3", "name": "foobar"])
        let expected = [a, c]

        let pred = NSPredicate(format: "name contains[c] %@", "foo")
        let sort = [NSSortDescriptor(key: "name", ascending: true)]

        //  when
        let frc = database.fetchedResultsController(predicate: pred, sortDescriptors: sort, sectionNameKeyPath: nil) as FetchedResultsController<Course>
        frc.performFetch()
        let objs = frc.fetchedObjects

        //  then
        XCTAssertEqual(objs, expected)
    }

    func assertNoCourseObjectsPreExisting() {
        let objs: [Course] = client.fetch()
        XCTAssertEqual(objs.count, 0)
    }
}

extension PersistenceTests: FetchedResultsControllerDelegate {
    func controllerDidChangeContent<T>(_ controller: FetchedResultsController<T>) {
        frcExpectation.fulfill()
    }
}
