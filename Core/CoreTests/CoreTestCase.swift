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

import Foundation
import XCTest
import RealmSwift
@testable import Core
import TestsFoundation

class CoreTestCase: XCTestCase {
    let api = MockAPI()
    var db: Persistence!
    let queue = TestOperationQueue()
    let router = TestRouter()

    lazy var environment: AppEnvironment = {
        return AppEnvironment(api: api, database: db, queue: queue, router: router)
    }()

    override func setUp() {
        super.setUp()
        let config = RealmPersistence.testingConfig(identifier: self.name)
        db = RealmPersistence(configuration: config)
    }

    @discardableResult func course(_ template: Template = [:]) -> Course {
        return db.make(template)
    }

    @discardableResult func group(_ template: Template = [:]) -> Group {
        return db.make(template)
    }

    @discardableResult func tab(_ template: Template = [:]) -> Tab {
        return db.make(template)
    }

    @discardableResult func assignment(_ template: Template = [:]) -> Assignment {
        return db.make(template)
    }

    @discardableResult func submission(_ template: Template = [:]) -> Submission {
        return db.make(template)
    }

    func addOperationAndWait(_ operation: Operation) {
        let expectation = XCTestExpectation(description: "expectation")
        operation.completionBlock = {
            expectation.fulfill()
        }
        queue.addOperation(operation)
        wait(for: [expectation], timeout: 0.1)
    }
}
