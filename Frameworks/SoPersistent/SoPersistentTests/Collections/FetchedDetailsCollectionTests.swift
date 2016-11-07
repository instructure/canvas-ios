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
    
    

import Foundation
import SoPersistent
import SoAutomated
import TooLegit

class FetchedDetailsCollectionTest: XCTestCase {

    func testDescribeFetchedDetailsCollection() {
        let session = Session.inMemory
        let managedObjectContext = try! session.soPersistentTestsManagedObjectContext()
        let object = Panda.build(managedObjectContext)
        object.name = "ABCD"
        let predicate = NSPredicate(format: "%K == %@", "id", object.id)
        let observer = try! ManagedObjectObserver<Panda>(predicate: predicate, inContext: managedObjectContext)
        let detailsFactory: Panda->[String] = { $0.name.characters.map { String($0) } }

        let fdc = FetchedDetailsCollection(observer: observer, detailsFactory: detailsFactory)

        describe("the details") {
            it("has the correct number of items") {
                XCTAssertEqual(4, fdc.numberOfItemsInSection(0))
            }

            it("maps updates the object to details") {
                XCTAssertEqual("A", fdc[NSIndexPath(forRow: 0, inSection: 0)])
                XCTAssertEqual("B", fdc[NSIndexPath(forRow: 1, inSection: 0)])
                XCTAssertEqual("C", fdc[NSIndexPath(forRow: 2, inSection: 0)])
                XCTAssertEqual("D", fdc[NSIndexPath(forRow: 3, inSection: 0)])
            }

            context("when the managed object changes") {
                it("updates the details") {
                    object.name = "ZYXW"
                    managedObjectContext.processPendingChanges()
                    XCTAssertEqual("Z", fdc[NSIndexPath(forRow: 0, inSection: 0)])
                    XCTAssertEqual("Y", fdc[NSIndexPath(forRow: 1, inSection: 0)])
                    XCTAssertEqual("X", fdc[NSIndexPath(forRow: 2, inSection: 0)])
                    XCTAssertEqual("W", fdc[NSIndexPath(forRow: 3, inSection: 0)])
                }
            }
        }

        describe("sections") {
            it("has nil section titles") {
                XCTAssertNil(fdc.titleForSection(0))
            }

            it("has only one section") {
                XCTAssertEqual(1, fdc.numberOfSections())
            }
        }

    }
}
