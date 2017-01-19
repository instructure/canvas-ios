//
// Copyright (C) 2016-present Instructure, Inc.
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
@testable import EnrollmentKit
import TooLegit
import CoreData
import SoAutomated
import SoPersistent
import Nimble

class GroupCollectionsTests: XCTestCase {
    let session = Session.art
    var context: NSManagedObjectContext!
    
    lazy var studentContext: (String)->NSManagedObjectContext = { studentID in
        return try! self.session.enrollmentManagedObjectContext(studentID)
    }
    
    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }
    
    // MARK: favoritesCollection
    
    func testGroup_favoritesCollection_includesGroupsWithIsFavoriteFlag() {
        let favorite = Group.build(inSession: session) { $0.isFavorite = true }
        let collection = try! Group.favoritesCollection(session)
        XCTAssert(collection.contains(favorite), "favoritesCollection includes groups with isFavorite flag")
    }
    
    func testGroup_favoritesCollection_excludesGroupsWithoutIsFavoriteFlag() {
        let nonFavorite = Group.build(inSession: session) { $0.isFavorite = false }
        let collection = try! Group.favoritesCollection(session)
        XCTAssertFalse(collection.contains(nonFavorite), "favoritesCollection excludes groups with isFavorite flag")
    }
    
    func testGroup_favoritesCollection_sortsByNameThenByID() {
        let first = Group.build(inSession: session) {
            $0.name = "A"
            $0.id = "1"
            $0.isFavorite = true
        }
        let second = Group.build(inSession: session) {
            $0.name = "B"
            $0.id = "2"
            $0.isFavorite = true
        }
        let third = Group.build(inSession: session) {
            $0.name = "B"
            $0.id = "3"
            $0.isFavorite = true
        }
        let collection = try! Group.favoritesCollection(session)
        XCTAssertEqual(collection[0, 0], first)
        XCTAssertEqual(collection[0, 1], second)
        XCTAssertEqual(collection[0, 2], third)
    }
    
    // MARK: refresher
    
    func testGroup_refresher_syncsGroups() {
        let refresher = try! Group.refresher(session)
        let count = Group.observeCount(inSession: session)
        expect {
            refresher.playback("refresh-all-groups", with: self.session)
        }.to(change({ count.currentCount }, from: 0, to: 2))
    }
    
    func testGroup_refresher_syncsFavoriteColors() {
        let group = Group.build(inSession: session) {
            $0.id = "337865"
            $0.color.value = .black
        }
        let refresher = try! Group.refresher(session)
        refresher.playback("refresh-all-groups", with: session)
        XCTAssertEqual("#F06291", group.color.value?.hex, "refresher syncs favorite colors")
    }
}
