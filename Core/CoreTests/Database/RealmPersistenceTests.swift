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
    var realm: Realm! = nil
    var config: Realm.Configuration!

    override func setUp() {
        super.setUp()
        do {
            config = RealmPersistence.testingConfig(inMemoryIdentifier: self.name)
            try realm = Realm(configuration: config)
            p = RealmPersistence(configuration: config)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInsert() {
        var objs = realm.objects(Course.self)
        XCTAssertEqual(objs.count, 0)

        let name = "test object"

        let model: Course = p.insert()
        model.name = name
        model.id = "1"
        try? p.addOrUpdate(model)

        objs = realm.objects(Course.self)
        XCTAssertEqual(objs.count, 1)
        XCTAssertEqual(objs.first?.name, name)
    }

    func testInsertOfExistingObject() {
        var objs = realm.objects(Course.self)
        XCTAssertEqual(objs.count, 0)

        let a: Course = p.insert()
        a.name = "foo"
        a.id = "1"

        try? p.addOrUpdate(a)
        objs = realm.objects(Course.self)
        XCTAssertEqual(objs.count, 1)

        let b: Course = p.insert()
        b.name = "bar"
        b.id = "1"

        do {
            try p.addOrUpdate(b)
        } catch {
            print(error)
        }

        objs = realm.objects(Course.self)
        print(objs)
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

        let objs = realm.objects(Course.self)
        XCTAssertEqual(objs.first!.name, "aa")
        XCTAssertEqual(objs.last!.name, "bb")
        XCTAssertEqual(objs.count, 2)
    }

    func testDelete() {
        let a = Course(value: ["id": "1", "name": "a"])
        try? p.addOrUpdate(a)

        var objs = realm.objects(Course.self)
        XCTAssertEqual(objs.count, 1)

        try? p.delete(a)

        objs = realm.objects(Course.self)
        XCTAssertEqual(objs.count, 0)
    }

    func testPerformSaveOnBackground() {
        let objs = realm.objects(Course.self)
        XCTAssertEqual(objs.count, 0)

        let expectation = XCTestExpectation(description: "expectation")
        RealmPersistence.performBackgroundTask { [weak self] (persistence) in

            let a = self!.p!
            let b = persistence as! RealmPersistence
            XCTAssertFalse(a.store === b.store)

            let model = Course(value: ["id": "1", "name": "a"])
            try? persistence.addOrUpdate(model)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        let models: [Course] = p.fetch(predicate: nil, sortDescriptors: nil)
        XCTAssertEqual(models.count, 1)
    }

    func testPerformSaveOnBackgroundWithExistingObject() {
        let model = Course(value: ["id": "1", "name": "a"])
        try? p.addOrUpdate(model)
        let expectedName = "updated"

        let expectation = XCTestExpectation(description: "expectation")
        RealmPersistence.performBackgroundTask { [weak self] (persistence) in

            let a = self!.p!
            let b = persistence as! RealmPersistence
            XCTAssertFalse(a.store === b.store)

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

    func testFetchWithPredicate() {
        let a = Course(value: ["id": "1", "name": "a"])
        let b = Course(value: ["id": "2", "name": "b"])

        try? p.addOrUpdate([a, b])

        let objs = realm.objects(Course.self)
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
}

extension RealmPersistence {
    static func testingConfig(inMemoryIdentifier: String) -> Realm.Configuration {
        var config = Realm.Configuration.defaultConfiguration
        config.inMemoryIdentifier = inMemoryIdentifier
        RealmPersistence.config.inMemoryIdentifier = inMemoryIdentifier
        return config
    }
}
