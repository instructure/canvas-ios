//
//  GradingPeriodHeaderSpec.swift
//  Enrollments
//
//  Created by Nathan Armstrong on 8/29/16.
//  Copyright © 2016 Instructure Inc. All rights reserved.
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
