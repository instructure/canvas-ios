//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import XCTest
@testable import Core

class ScopeTests: CoreTestCase {

    func test_init_withPredicateAndOrder() {
        let predicate = NSPredicate(format: "name == %@", "test")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let scope = Scope(predicate: predicate, order: [sortDescriptor], sectionNameKeyPath: "section")

        XCTAssertEqual(scope.predicate, predicate)
        XCTAssertEqual(scope.order, [sortDescriptor])
        XCTAssertEqual(scope.sectionNameKeyPath, "section")
    }

    func test_init_withPredicateOrderByString() {
        let predicate = NSPredicate(format: "id == %@", "123")
        let scope = Scope(predicate: predicate, orderBy: "name", ascending: false, naturally: true, sectionNameKeyPath: "category")

        XCTAssertEqual(scope.predicate, predicate)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "name")
        XCTAssertFalse(scope.order.first?.ascending ?? true)
        XCTAssertEqual(scope.sectionNameKeyPath, "category")
    }

    func test_init_withPredicateOrderByKeyPath() {
        let predicate = NSPredicate(format: "active == %@", NSNumber(value: true))
        let scope = Scope(
            predicate: predicate,
            orderBy: \Course.name,
            ascending: true,
            naturally: false,
            sectionNameKeyPath: \Course.id
        )

        XCTAssertEqual(scope.predicate, predicate)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "name")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
        XCTAssertEqual(scope.sectionNameKeyPath, "id")
    }

    func test_where_stringEqualsNonNilValue() {
        let scope = Scope.where("courseID", equals: "123", orderBy: "name", ascending: true, naturally: false)

        let expectedPredicate = NSPredicate(format: "%K == %@", argumentArray: ["courseID", "123"])
        XCTAssertEqual(scope.predicate, expectedPredicate)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "name")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
    }

    func test_where_stringEqualsNilValue() {
        let scope = Scope.where("parentID", equals: nil, orderBy: "position", ascending: false, naturally: true)

        let expectedPredicate = NSPredicate(format: "%K == nil", "parentID")
        XCTAssertEqual(scope.predicate, expectedPredicate)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "position")
        XCTAssertFalse(scope.order.first?.ascending ?? true)
    }

    func test_where_stringEqualsDefaultOrder() {
        let scope = Scope.where("status", equals: "active")

        let expectedPredicate = NSPredicate(format: "%K == %@", argumentArray: ["status", "active"])
        XCTAssertEqual(scope.predicate, expectedPredicate)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "status")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
    }

    func test_where_keyPathEquals() {
        let scope = Scope.where(\Course.id, equals: "123", ascending: false, naturally: true)

        let expectedPredicate = NSPredicate(format: "%K == %@", argumentArray: ["id", "123"])
        XCTAssertEqual(scope.predicate, expectedPredicate)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "id")
        XCTAssertFalse(scope.order.first?.ascending ?? true)
    }

    func test_where_keyPathEqualsWithOrderKeyPath() {
        let scope = Scope.where(\Course.id, equals: "123", orderBy: \Course.name, ascending: true, naturally: false)

        let expectedPredicate = NSPredicate(format: "%K == %@", argumentArray: ["id", "123"])
        XCTAssertEqual(scope.predicate, expectedPredicate)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "name")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
    }

    func test_where_stringEqualsWithSortDescriptors() {
        let sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "id", ascending: false)
        ]
        let scope = Scope.where("active", equals: NSNumber(value: true), sortDescriptors: sortDescriptors)

        let expectedPredicate = NSPredicate(format: "%K == %@", argumentArray: ["active", NSNumber(value: true)])
        XCTAssertEqual(scope.predicate, expectedPredicate)
        XCTAssertEqual(scope.order, sortDescriptors)
    }

    func test_where_keyPathEqualsWithSortDescriptors() {
        let sortDescriptors = [
            NSSortDescriptor(key: "position", ascending: true),
            NSSortDescriptor(key: "name", ascending: false)
        ]
        let scope = Scope.where(\Course.id, equals: "456", sortDescriptors: sortDescriptors)

        let expectedPredicate = NSPredicate(format: "%K == %@", argumentArray: ["id", "456"])
        XCTAssertEqual(scope.predicate, expectedPredicate)
        XCTAssertEqual(scope.order, sortDescriptors)
    }

    func test_all_withStringOrderBy() {
        let scope = Scope.all(orderBy: "name", ascending: false, naturally: true)

        XCTAssertEqual(scope.predicate, .all)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "name")
        XCTAssertFalse(scope.order.first?.ascending ?? true)
    }

    func test_all_withKeyPathOrderBy() {
        let scope = Scope.all(orderBy: \Course.name, ascending: true, naturally: false)

        XCTAssertEqual(scope.predicate, .all)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "name")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
    }

    func test_all_default() {
        let scope = Scope.all

        XCTAssertEqual(scope.predicate, .all)
        XCTAssertEqual(scope.order.count, 1)
        XCTAssertEqual(scope.order.first?.key, "objectID")
        XCTAssertTrue(scope.order.first?.ascending ?? false)
    }

    func test_equality_scopeComparison() {
        let predicate = NSPredicate(format: "name == %@", "test")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)

        let scope1 = Scope(predicate: predicate, order: [sortDescriptor], sectionNameKeyPath: "section")
        let scope2 = Scope(predicate: predicate, order: [sortDescriptor], sectionNameKeyPath: "section")
        let scope3 = Scope(predicate: predicate, order: [sortDescriptor], sectionNameKeyPath: "different")

        XCTAssertEqual(scope1, scope2)
        XCTAssertNotEqual(scope1, scope3)
    }

    func test_NSSortDescriptor_stringInit() {
        let descriptor1 = NSSortDescriptor(key: "name", ascending: true, naturally: false)
        XCTAssertEqual(descriptor1.key, "name")
        XCTAssertTrue(descriptor1.ascending)
        XCTAssertEqual(descriptor1.selector, #selector(NSString.compare(_:)))

        let descriptor2 = NSSortDescriptor(key: "title", ascending: false, naturally: true)
        XCTAssertEqual(descriptor2.key, "title")
        XCTAssertFalse(descriptor2.ascending)
        XCTAssertEqual(descriptor2.selector, #selector(NSString.localizedStandardCompare(_:)))
    }

    func test_NSSortDescriptor_keyPathInit() {
        let descriptor1 = NSSortDescriptor(keyPath: \Course.name, ascending: true, naturally: false)
        XCTAssertEqual(descriptor1.key, "name")
        XCTAssertTrue(descriptor1.ascending)
        XCTAssertEqual(descriptor1.selector, #selector(NSString.compare(_:)))

        let descriptor2 = NSSortDescriptor(keyPath: \Course.id, ascending: false, naturally: true)
        XCTAssertEqual(descriptor2.key, "id")
        XCTAssertFalse(descriptor2.ascending)
        XCTAssertEqual(descriptor2.selector, #selector(NSString.localizedStandardCompare(_:)))
    }
}
