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
import SoPersistent
import TooLegit

class GradingPeriodDetailsTests: XCTestCase {
    func testObserverObservesChanges() {
        let session = Session.inMemory
        let context = try! session.enrollmentManagedObjectContext()
        let gradingPeriod = GradingPeriod.build(context, id: "1", courseID: "1")
        try! context.save()
        let observer = try! GradingPeriod.observer(session, id: "1", courseID: "1")
        let expectation = self.expectation(description: "it should observe changes")

        observer.signal.observeValues { change, gradingPeriod in
            if let title = gradingPeriod?.title, title == "observer" && change == .update {
                expectation.fulfill()
            }
        }

        gradingPeriod.title = "observer"
        waitForExpectations(timeout: 1, handler: nil)
    }
}
