
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
    
    

@testable import AssignmentKit
import Quick
import Nimble
import SoAutomated
import TooLegit
@testable import FileKit
import CoreData
import SoPersistent
import ReactiveCocoa
import Result

extension Upload {
    public static func observer(session: Session, backgroundSessionID: String) throws -> ManagedObjectObserver<Upload> {
        let predicate = NSPredicate(format: "%K == %@", "backgroundSessionID", backgroundSessionID)
        let context = try session.assignmentsManagedObjectContext()
        return try ManagedObjectObserver(predicate: predicate, inContext: context)
    }
}

extension Credentials {
    static let mbl6745User = Credentials(
        id: "17",
        domain: "cwilliams.instructure.com",
        email: "narmstrong",
        password: "X8UwbcduxaP,y",
        token: "5648~pLTgjBHpwCVz45kSES3PJpisHxrPLPPImHqjaX7Xoq5EsJAaCa5bae6hK7MzLxPr",
        name: "Hank Aaron"
    )
}

class SubmissionUploadSpec: QuickSpec {
    override func spec() {
        describe("submission uploads") {
            var session: Session!
            var assignment: Assignment!
            beforeEach {
                session = User(credentials: .user4).session
                assignment = Assignment.build(inSession: session) {
                    $0.id = "1252468"
                    $0.courseID = "24219"
                }
            }

            describe("TextSubmissionUpload") {
                it("should create a submission") {
                    let upload = TextSubmissionUpload.create(backgroundSessionID: "unit test", assignment: assignment, text: "This is some text", inContext: assignment.managedObjectContext!)
                    let count = Submission.observeCount(inSession: session)
                    expect {
                        session.playback("upload-text-submission", in: currentBundle) {
                            uploadSubmission(upload, in: session)
                        }
                    }.to(change({ count.currentCount }, from: 0, to: 1))
                }
            }

            describe("URLSubmissionUpload") {
                it("should create a submission") {
                    let upload = URLSubmissionUpload.create(backgroundSessionID: "unit test", assignment: assignment, url: "http://google.com", inContext: assignment.managedObjectContext!)
                    let count = Submission.observeCount(inSession: session)
                    expect {
                        session.playback("upload-url-submission", in: currentBundle) {
                            uploadSubmission(upload, in: session)
                        }
                    }.to(change({ count.currentCount }, from: 0, to: 1))
                }
            }

            describe("FileSubmissionUpload") {
                it("should create a submission") {
                    let newUpload = NewUpload.FileUpload([.FileURL(factoryURL)])
                    var upload: FileSubmissionUpload!
                    waitUntil { done in
                        try! assignment.uploadForNewSubmission(newUpload, inSession: session) {
                            expect($0).to(beAnInstanceOf(FileSubmissionUpload))
                            upload = $0 as! FileSubmissionUpload
                            done()
                        }
                    }
                    let count = Submission.observeCount(inSession: session)
                    expect {
                        session.playback("upload-file-submission", in: currentBundle) {
                            uploadSubmission(upload, in: session)
                        }
                    }.to(change({ count.currentCount }, from: 0, to: 1))
                }
            }
        }
    }
}
