
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
    
    

@testable import PageKit
import SoAutomated
import XCTest
import TooLegit
import DoNotShipThis
import CoreData
import SoPersistent
import ReactiveCocoa
import Marshal
import Nimble

let currentBundle = NSBundle(forClass: PageCollectionsTest.self)

class PageCollectionsTest: UnitTestCase {
    
    let session = Session.ivy
    
    var defaultContextID: ContextID {
        return ContextID(id: "24601", context: .Course)
    }
    
    var realContextID: ContextID {
        return ContextID(id: "24219", context: .Course)
    }

    func testRoutingUrl_isTheCorrectPath() {
        attempt {
            let page = try Page.build(session.pagesManagedObjectContext())

            let url = page.routingUrl

            XCTAssertEqual(url.absoluteString, "file:///api/v1/courses/24601/pages/page")
        }
    }

    func testRefresher_itSyncsAllPages() {
        attempt {
            let context = try session.pagesManagedObjectContext()
            let refresher = try Page.refresher(session, contextID: realContextID)

            expect {
                refresher.playback("pages-list", in: currentBundle, with: self.session)
            }.to(change({ Page.count(inContext: context) }, from: 0, to: 17))
        }
    }

    func testAlphabeticalCollectionFetch_itFetchesOnlyPublishedPages() {
        attempt {
            let context = try session.pagesManagedObjectContext()
            let publishedPage = Page.build(context)
            let unpublishedPage = Page.build(context, published: false)

            guard let collection = try? Page.collectionAlphabetical(session, contextID: defaultContextID) else {
                XCTFail("expected collection")
                return
            }

            XCTAssertFalse(collection.contains(unpublishedPage))
            XCTAssert(collection.contains(publishedPage))
        }
    }

    func testAlphabeticalCollectionFetch_itReturnsOnlyPagesWithTheMatchingContextID() {
        attempt {
            let context = try session.pagesManagedObjectContext()
            let pageWithMatchingID = Page.build(context, contextID: defaultContextID)
            let pageWithWrongID = Page.build(context, contextID: ContextID(id: "12345", context: .Course))

            guard let collection = try? Page.collectionAlphabetical(session, contextID: defaultContextID) else {
                XCTFail("expected collection")
                return
            }

            XCTAssert(collection.contains(pageWithMatchingID))
            XCTAssertFalse(collection.contains(pageWithWrongID))
        }
    }

    func testAlphabeticalCollectionFetch_itReturnsTheCorrectOrder() {
        attempt {
            let context = try session.pagesManagedObjectContext()
            let page1 = Page.build(context)
            page1.title = "z"
            let page2 = Page.build(context)
            page2.title = "a"
            let page3 = Page.build(context)
            page3.title = "d"

            guard let collection = try? Page.collectionAlphabetical(session, contextID: defaultContextID) else {
                XCTFail("expected collection")
                return
            }
            
            XCTAssertEqual(collection[pathForRow(0)].title, page2.title)
            XCTAssertEqual(collection[pathForRow(1)].title, page3.title)
            XCTAssertEqual(collection[pathForRow(2)].title, page1.title)
        }
    }
    
    func pathForRow(row: Int) -> NSIndexPath {
        return NSIndexPath(forRow: row, inSection: 0)
    }
    
}
