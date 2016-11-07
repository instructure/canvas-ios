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
import SoAutomated
import Marshal
import CoreData
import TooLegit
import DoNotShipThis

class GradingPeriodTests: XCTestCase {

    // MARK: - Model

    func testGradingPeriod_isValid() {
        attempt {
            let session = Session.inMemory
            let context = try session.enrollmentManagedObjectContext()
            let gradingPeriod = GradingPeriod.build(context)
            XCTAssert(gradingPeriod.isValid)
        }
    }

    func testGradingPeriod_updateValues() {
        attempt {

            // Given
            let json = [
                "id": "54321",
                "title": "Update Values",
                "start_date": "2014-01-07T15:04:00Z"
            ]
            let session = Session.inMemory
            let context = try session.enrollmentManagedObjectContext()
            let gradingPeriod = GradingPeriod(inContext: context)

            // When
            try gradingPeriod.updateValues(json, inContext: context)

            // Then
            XCTAssertEqual("54321", gradingPeriod.id)
            XCTAssertEqual("Update Values", gradingPeriod.title)
            XCTAssertNotNil(gradingPeriod.startDate)

        }
    }
}
