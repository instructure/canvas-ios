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
import Marshal
import Nimble

class TabCollectionsTests: UnitTestCase {
    let session = Session.art
    var context: NSManagedObjectContext!
   
    // MARK: collection

    func testTab_collection_sortsByPosition() {
        attempt {
            context = try session.enrollmentManagedObjectContext()
            let first = Tab.build(inSession: session)
            try first.updateValues(tabJSON(1), inContext: context)
            let third = Tab.build(inSession: session)
            try third.updateValues(tabJSON(3), inContext: context)
            let second = Tab.build(inSession: session)
            try second.updateValues(tabJSON(2), inContext: context)
            let contextID: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            let collection = try Tab.collection(session, contextID: contextID)
            XCTAssert(collection[0, 0] === first)
            XCTAssert(collection[0, 1] === second)
            XCTAssert(collection[0, 2] === third)
        }
    }
    
    func testTab_shortcuts() {
        attempt {
            context = try session.enrollmentManagedObjectContext()
            let tab = Tab.build(inSession: session)
            try tab.updateValues(tabJSON(1), inContext: context)
            let contextID: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            let shortcuts = try Tab.shortcuts(session, contextID: contextID)
            XCTAssert(shortcuts[0, 0] === tab)
        }
    }
    
    // MARK: refresher
    
    func testTab_refresher() {
        attempt {
            context = try session.enrollmentManagedObjectContext()
            let contextID: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            let refresher = try Tab.refresher(session, contextID: contextID)
            let count = Tab.observeCount(inSession: session)
            expect {
                refresher.playback("refresh-all-tabs", in: currentBundle, with: self.session)
            }.to(change({ count.currentCount}, from: 0, to: 5))
        }
    }
    
    private func tabJSON(position: Int) -> JSONObject {
        return [
            "url": "https://mobiledev.instructure.com/api/v1/courses/1422605",
            "id": "files",
            "position": position,
            "label": "1",
        ]
    }
}

//MARK: tableViewController

class TabTableViewControllerTests: UnitTestCase {
    let session = Session.art
    let tvc = Tab.TableViewController()
    let viewModelFactory = ViewModelFactory<Tab>.new { _ in UITableViewCell() }
    
    func testTableViewController_prepare_setsCollection() {
        attempt {
            let contextID: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            let collection = try Tab.collection(session, contextID: contextID)
            tvc.prepare(collection, viewModelFactory: viewModelFactory)
            XCTAssertEqual(collection, tvc.collection, "prepare sets the collection")
        }
    }
    
    func testTableViewController_prepare_setsRefresher() {
        attempt {
            let contextID: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            let collection = try Tab.collection(session, contextID: contextID)
            let refresher = try Tab.refresher(session, contextID: contextID)
            tvc.prepare(collection, refresher: refresher, viewModelFactory: viewModelFactory)
            XCTAssertNotNil(tvc.refresher, "prepare sets the refresher")
        }
    }
    
    func testTableViewController_prepare_setsDataSource() {
        attempt {
            let contextID: ContextID = ContextID(url: NSURL(string: "https://mobiledev.instructure.com/api/v1/courses/1422605")!)!
            let collection = try Tab.collection(session, contextID: contextID)
            tvc.prepare(collection, viewModelFactory: viewModelFactory)
            XCTAssertNotNil(tvc.dataSource, "prepare sets the data source")
        }
    }
}

