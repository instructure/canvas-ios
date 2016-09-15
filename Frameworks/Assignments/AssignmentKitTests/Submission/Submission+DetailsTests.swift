//
//  Submission+DetailsTests.swift
//  Assignments
//
//  Created by Nathan Lambson on 6/1/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Quick
import Nimble
import SoAutomated
import TooLegit
import ReactiveCocoa
import Marshal
@testable import AssignmentKit

class SubmissionDetailsSpec: QuickSpec {
    override func spec() {
        describe("Submission Details") {
            describe("#refreshSignalProducer") {
                it("creates a submission") {
                    let user = User(credentials: .user1)
                    let moc = try! user.session.assignmentsManagedObjectContext()
                    let stub = Stub(session: user.session, name: "refresh-submission", testCase: self, bundle: NSBundle(forClass: SubmissionDetailsSpec.self))
                    self.assertDifference({ Submission.count(inContext: moc) }, 1) {
                        try Submission.refreshSignalProducer(user.session, courseID: "1867097", assignmentID: "9599332").startWithStub(stub)
                    }
                }
            }
        }
    }
}
