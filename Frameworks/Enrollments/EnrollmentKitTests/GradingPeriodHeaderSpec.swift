
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
    
    

import Quick
import Nimble
import SoAutomated
@testable import EnrollmentKit

class GradingPeriodHeaderSpec: QuickSpec {
    override func spec() {
        describe("GradingPeriod.Header") {
            describe("selectedGradingPeriod") {
                it("should be nil if includeGradingPeriods is false") {
                    let session = User(credentials: .user1).session
                    let course = Course.build(inSession: session)
                    let header = try! GradingPeriod.Header(session: session, courseID: course.id, viewController: UIViewController(), includeGradingPeriods: false)
                    expect(header.selectedGradingPeriod.value).to(beNil())
                }
            }
        }
    }
}
