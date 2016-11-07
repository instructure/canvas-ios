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
import SoAutomated
@testable import SoPersistent
import TooLegit

class CollectionUpdateTests: XCTestCase {

    typealias CUP = CollectionUpdate<Panda>

    func testDescribeMap() {
        context("when it is a section") {
            it("returns a copy of itself") {
                let insert = CUP.SectionInserted(0).map({ $0 })
                let delete = CUP.SectionDeleted(0).map({ $0 })
                XCTAssert(insert == .SectionInserted(0))
                XCTAssert(delete == .SectionDeleted(0))
            }
        }

        context("when it is not a section") {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            let session = Session.inMemory
            let context = try! session.soPersistentTestsManagedObjectContext()
            let panda = Panda.build(context)

            it("maps Inserted") {
                let insert = CUP.Inserted(indexPath, panda).map({ $0.name })
                XCTAssert(insert == .Inserted(indexPath, panda.name))
            }

            it("maps Updated") {
                let update = CUP.Updated(indexPath, panda).map({ $0.name })
                XCTAssert(update == .Updated(indexPath, panda.name))
            }

            it("maps Moved") {
                let moved = CUP.Moved(indexPath, indexPath, panda).map({ $0.name })
                XCTAssert(moved == .Moved(indexPath, indexPath, panda.name))
            }

            it("maps Deleted") {
                let deleted = CUP.Deleted(indexPath, panda).map({ $0.name })
                XCTAssert(deleted == .Deleted(indexPath, panda.name))
            }
        }
    }
}
