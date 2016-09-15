//
//  Group+CollectionsTest.swift
//  Enrollments
//
//  Created by Egan Anderson on 6/30/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
//

import XCTest
@testable import EnrollmentKit
import TooLegit
import CoreData
import SoAutomated
import SoPersistent

class GroupCollectionsTests: UnitTestCase {
    let session = Session.art
    var context: NSManagedObjectContext!
    
    lazy var studentContext: String->NSManagedObjectContext = { studentID in
        var context: NSManagedObjectContext!
        self.attempt {
            context = try self.session.enrollmentManagedObjectContext(studentID)
        }
        return context
    }
    
    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }
    
    // MARK: favoritesCollection
    
    func testGroup_favoritesCollection_includesGroupsWithIsFavoriteFlag() {
        let favorite = Group.build(context, isFavorite: true)
        attempt {
            let collection = try Group.favoritesCollection(session)
            XCTAssert(collection.contains(favorite), "favoritesCollection includes groups with isFavorite flag")
        }
    }
    
    func testGroup_favoritesCollection_excludesGroupsWithoutIsFavoriteFlag() {
        let nonFavorite = Group.build(context, isFavorite: false)
        attempt {
            let collection = try Group.favoritesCollection(session)
            XCTAssertFalse(collection.contains(nonFavorite), "favoritesCollection excludes groups with isFavorite flag")
        }
    }
    
    func testGroup_favoritesCollection_sortsByNameThenByID() {
        let first = Group.build(context, name: "A", id: "1", isFavorite: true)
        let second = Group.build(context, name: "B", id: "2", isFavorite: true)
        let third = Group.build(context, name: "B", id: "3", isFavorite: true)
        attempt {
            let collection = try Group.favoritesCollection(session)
            XCTAssertEqual([first, second, third], collection.allObjects, "favoritesCollection sorts by name then by id")
        }
    }
    
    // MARK: refresher
    
    func testGroup_refresher_syncsGroups() {
        attempt {
            let refresher = try Group.refresher(session)
            assertDifference({ Group.count(inContext: context) }, 2, "refresher syncs groups") {
                stub(session, "refresh-all-groups") { expectation in
                    refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
                    refresher.refresh(true)
                }
            }
        }
    }
    
    func testGroup_refresher_syncsFavoriteColors() {
        attempt {
            let group = Group.build(context, id: "24219", color: nil)
            try context.save()
            let refresher = try Group.refresher(session)
            stub(session, "refresh-all-groups") { expectation in
                refresher.refreshingCompleted.observeNext(self.refreshCompletedWithExpectation(expectation))
                refresher.refresh(true)
            }
            XCTAssertEqual("#555555", group.rawColor, "refresher syncs favorite colors")
        }
    }
}
