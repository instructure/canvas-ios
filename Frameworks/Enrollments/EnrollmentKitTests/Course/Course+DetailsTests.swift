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
import CoreData
@testable import EnrollmentKit
import SoAutomated
import TooLegit
import DoNotShipThis

class CourseDetailsTests: UnitTestCase {
    let session = Session.inMemory
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        attempt {
            context = try session.enrollmentManagedObjectContext()
        }
    }

    func testCourse_observer_observesCourse() {
        attempt {
            let observer = try Course.observer(session, courseID: "1")
            let e = expectation(description: "it observes course matching id")
            observer.signal.observeResult { result in
                switch result {
                case .success(let value):
                    if value.0 == .insert {
                        e.fulfill()
                    }
                default: break
                }
            }
            Course.build(inSession: session) { $0.id = "1" }
            waitForExpectations(timeout: 1, handler: nil)
        }
    }
}
