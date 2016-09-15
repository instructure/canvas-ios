//
//  CollectionTests.swift
//  SoPersistent
//
//  Created by Nathan Armstrong on 3/8/16.
//  Copyright © 2016 Instructure. All rights reserved.
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
