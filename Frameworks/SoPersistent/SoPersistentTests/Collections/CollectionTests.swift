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
                let insert = CUP.sectionInserted(0).map({ $0 })
                let delete = CUP.sectionDeleted(0).map({ $0 })
                XCTAssert(insert == .sectionInserted(0))
                XCTAssert(delete == .sectionDeleted(0))
            }
        }

        context("when it is not a section") {
            let indexPath = IndexPath(row: 0, section: 0)
            let session = Session.inMemory
            let context = try! session.soPersistentTestsManagedObjectContext()
            let panda = Panda.build(context)

            it("maps Inserted") {
                let insert = CUP.inserted(indexPath, panda, animated: false).map({ $0.name })
                XCTAssert(insert == CollectionUpdate.inserted(indexPath, panda.name, animated: false))
            }

            it("maps Updated") {
                let update = CUP.updated(indexPath, panda, animated: false).map({ $0.name })
                XCTAssert(update == .updated(indexPath, panda.name, animated: false))
            }

            it("maps Moved") {
                let moved = CUP.moved(indexPath, indexPath, panda, animated: false).map({ $0.name })
                XCTAssert(moved == .moved(indexPath, indexPath, panda.name, animated: false))
            }

            it("maps Deleted") {
                let deleted = CUP.deleted(indexPath, panda, animated: false).map({ $0.name })
                XCTAssert(deleted == .deleted(indexPath, panda.name, animated: false))
            }
        }
    }
}
