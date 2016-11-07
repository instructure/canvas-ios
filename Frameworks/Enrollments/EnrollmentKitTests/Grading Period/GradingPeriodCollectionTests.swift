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

class GradingPeriodItemTests: XCTestCase {
    func testTitle() {
        let session = Session.inMemory
        let context = try! session.enrollmentManagedObjectContext()
        var item: GradingPeriodItem

        item = .All
        XCTAssertEqual("All Grading Periods", item.title)

        item = .Some(GradingPeriod.build(context, title: "Quarter 1"))
        XCTAssertEqual("Quarter 1", item.title)
    }
}
