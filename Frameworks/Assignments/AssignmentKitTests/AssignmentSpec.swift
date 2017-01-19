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
import FileKit
import SoLazy
import MobileCoreServices
import Result

class AssignmentSpec: QuickSpec {
    override func spec() {
        describe("assignment model") {
            var assignment: Assignment!
            var session: Session!
            beforeEach {
                session = .user1
                assignment = Assignment(inContext: session.managedObjectContext(Assignment.self))
            }

            describe("grade") {
                it("should change based on grading type") {
                    assignment.gradingType = .notGraded
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "n/a"

                    assignment.gradingType = .letterGrade
                    assignment.currentGrade = "A-"
                    expect(assignment.grade) == "A-"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .gpaScale
                    assignment.currentGrade = "3.7"
                    expect(assignment.grade) == "3.7"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .passFail
                    assignment.currentGrade = "P"
                    expect(assignment.grade) == "P"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .percent
                    assignment.currentGrade = "90%"
                    expect(assignment.grade) == "90%"
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"

                    assignment.gradingType = .points
                    assignment.currentGrade = ""
                    assignment.pointsPossible = 100
                    expect(assignment.grade) == "-/100"
                    assignment.currentGrade = "10"
                    expect(assignment.grade) == "10/100"
                    assignment.currentGrade = "Not a number"
                    expect(assignment.grade) == "-/100"

                    assignment.gradingType = .error
                    assignment.currentGrade = ""
                    expect(assignment.grade) == "-"
                }
            }

            describe("due status") {
                context("when the assignment is submitted online and is past due") {
                    beforeEach {
                        var json = assignmentJSON
                        let due = Date(year: 2000, month: 1, day: 1)
                        json["due_at"] = jsonify(date: due)
                        json["submission_types"] = ["external_tool"]
                        json["has_submitted_submissions"] = false
                        json["locked_for_user"] = false
                        Clock.timeTravel(to: Date(year: 2000, month: 1, day: 2)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                    }

                    it("should be Overdue") {
                        expect(assignment.rawDueStatus) == DueStatus.Overdue.rawValue
                    }
                }

                context("when the submission type is not online and due date is in the past") {
                    it("should be past due") {
                        var json = assignmentJSON
                        let due = Date(year: 2000, month: 1, day: 1)
                        json["submission_types"] = ["on_paper"]
                        json["due_at"] = jsonify(date: due)
                        Clock.timeTravel(to: Date(year: 2000, month: 1, day: 2)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                        expect(assignment.rawDueStatus) == DueStatus.Past.rawValue
                    }
                }

                context("when the assignment has been graded and it is past due with no submission") {
                    it("should be marked as Past, not Overdue") {
                        var json = assignmentJSON
                        let due = Date(year: 2016, month: 9, day: 1)
                        json["due_at"] = jsonify(date: due)
                        let graded = Date(year: 2016, month: 10, day: 1)
                        json["submission"] = ["graded_at": jsonify(date: graded), "workflow_state": "graded", "grade": "A"]
                        Clock.timeTravel(to: Date(year: 2016, month: 10, day: 2)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                        expect(assignment.rawDueStatus) == DueStatus.Past.rawValue
                    }
                }

                context("when the assignment is upcoming") {
                    beforeEach {
                        var json = assignmentJSON
                        let due = Date(year: 2000, month: 1, day: 1)
                        json["due_at"] = jsonify(date: due)
                        Clock.timeTravel(to: Date(year: 1999, month: 12, day: 1)) {
                            try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                        }
                    }
                    
                    it("should be upcoming") {
                        expect(assignment.rawDueStatus) == DueStatus.Upcoming.rawValue
                    }
                }
            }

            describe("submission types") {
                it("should convert from json") {
                    var json = assignmentJSON
                    json["submission_types"] = [
                        "external_tool",
                        "discussion_topic",
                        "online_quiz"
                    ]
                    try! assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                    expect(assignment.submissionTypes.contains(.externalTool)) == true
                    expect(assignment.submissionTypes.contains(.discussionTopic)) == true
                    expect(assignment.submissionTypes.contains(.quiz)) == true
                }

                it("should not allow an empty html url with quiz type") {
                    var json = assignmentJSON
                    json["submission_types"] = ["online_quiz"]
                    json["html_url"] = ""
                    expect {
                        try assignment.updateValues(json, inContext: assignment.managedObjectContext!)
                    }.to(throwError())
                }

                context("uploads") {
                    it("should allow certain file types based on the extension") {
                        assignment.submissionTypes = [.upload]
                        assignment.allowedExtensions = nil
                        expect(assignment.allowsAllFiles) == true
                        expect(assignment.allowsPhotos) == true
                        expect(assignment.allowsVideo) == true
                        expect(assignment.allowsAudio) == true
                        expect(assignment.allowedImagePickerControllerMediaTypes.count) == 2
                        expect(assignment.allowedImagePickerControllerMediaTypes.contains(kUTTypeMovie as String)) == true
                        expect(assignment.allowedImagePickerControllerMediaTypes.contains(kUTTypeImage as String)) == true

                        assignment.allowedExtensions = ["pdf"]
                        expect(assignment.allowsAllFiles) == false
                        expect(assignment.allowsPhotos) == false
                        expect(assignment.allowsVideo) == false
                        expect(assignment.allowsAudio) == false
                        expect(assignment.allowedImagePickerControllerMediaTypes).to(beEmpty())

                        assignment.allowedExtensions = ["mp3"]
                        expect(assignment.allowsPhotos) == false
                        expect(assignment.allowsVideo) == false
                        expect(assignment.allowsAudio) == true
                        expect(assignment.allowedImagePickerControllerMediaTypes).to(beEmpty())

                        assignment.allowedExtensions = ["jpg"]
                        expect(assignment.allowsPhotos) == true
                        expect(assignment.allowsVideo) == false
                        expect(assignment.allowsAudio) == false
                        expect(assignment.allowedImagePickerControllerMediaTypes) == [kUTTypeImage as String]

                        assignment.allowedExtensions = ["mp4"]
                        expect(assignment.allowsPhotos) == false
                        expect(assignment.allowsVideo) == true
                        expect(assignment.allowsAudio) == false
                        expect(assignment.allowedImagePickerControllerMediaTypes) == [kUTTypeMovie as String]
                        
                        assignment.allowedExtensions = ["mp4", "mp3", "jpg"]
                        expect(assignment.allowsPhotos) == true
                        expect(assignment.allowsVideo) == true
                        expect(assignment.allowsAudio) == true
                        expect(assignment.allowedImagePickerControllerMediaTypes.count) == 2
                        expect(assignment.allowedImagePickerControllerMediaTypes.contains(kUTTypeMovie as String)) == true
                        expect(assignment.allowedImagePickerControllerMediaTypes.contains(kUTTypeImage as String)) == true
                    }
                }
            }

            describe("uploadForNewSubmission") {
                context("text submission") {
                    let submission = NewUpload.text("text")
                    var upload: TextSubmissionUpload!
                    beforeEach {
                        waitUntil { done in
                            try! assignment.uploadForNewSubmission(submission, inSession: session) {
                                upload = $0 as! TextSubmissionUpload
                                done()
                            }
                        }
                    }

                    it("sets the text") {
                        expect(upload.text) == "text"
                    }

                    it("sets the assignment") {
                        expect(upload.assignment) == assignment
                    }
                }

                context("url submission") {
                    let submission = NewUpload.url(URL(string: "http://google.com")!)
                    var upload: URLSubmissionUpload!
                    beforeEach {
                        waitUntil { done in
                            try! assignment.uploadForNewSubmission(submission, inSession: session) {
                                expect($0).to(beAnInstanceOf(URLSubmissionUpload.self))
                                upload = $0 as! URLSubmissionUpload
                                done()
                            }
                        }
                    }

                    it("sets the url") {
                        expect(upload.url) == "http://google.com"
                    }

                    it("sets the assignment") {
                        expect(upload.assignment) == assignment
                    }
                }

                context("file submission") {
                    let submission = NewUpload.fileUpload([.fileURL(factoryURL), .photo(factoryImage)])
                    var upload: FileSubmissionUpload!
                    beforeEach {
                        waitUntil { done in
                            try! assignment.uploadForNewSubmission(submission, inSession: session) {
                                expect($0).to(beAnInstanceOf(FileSubmissionUpload.self))
                                upload = $0 as! FileSubmissionUpload
                                done()
                            }
                        }
                        expect(upload).toNot(beNil())
                    }

                    it("creates file uploads") {
                        let fileUploads = upload.fileUploads.sorted { $0.name < $1.name } // [Photo, testfile.txt]
                        
                        let photo = fileUploads.first!
                        expect(photo.name) == "Photo"
                        expect(photo.contentType) == "image/jpeg"
                        expect(photo.data).toNot(beNil())
                        
                        let textFile = fileUploads.last!
                        expect(textFile.name) == "testfile.txt"
                        expect(textFile.contentType) == "text/plain"
                        expect(textFile.data).toNot(beNil())
                    }
                }
            }

            describe("uploadBackgroundSessionExists") {
                it("exists if there is an active upload") {
                    let moc = session.managedObjectContext(Assignment.self)
                    try! assignment.updateValues(assignmentJSON, inContext: moc)
                    
                    class DummyTask: URLSessionTask {
                        override var taskIdentifier: Int {
                            get { return 1 }
                            set {}
                        }
                    }

                    expect(assignment.uploadBackgroundSessionExists(session)) == false

                    let upload = TextSubmissionUpload.create(backgroundSessionID: assignment.submissionUploadIdentifier, assignment: assignment, text: "", inContext: moc)
                    upload.startWithTask(DummyTask())

                    // need to save context
                    try! moc.saveFRD()
                    
                    expect(assignment.uploadBackgroundSessionExists(session)) == true
                }
            }
            
            describe("assignment refreshers") {
                describe("refresher(session:courseID:gradingPeriodID:)") {
                    var session: Session!
                    beforeEach {
                        session = User(credentials: .user4).session
                    }
                    
                    it("should create assignments") {
                        let count = Assignment.observeCount(inSession: session)
                        let refresher = try! Assignment.refresher(session, courseID: "1867097", gradingPeriodID: nil)
                        expect {
                            refresher.playback("assignment-grades", with: session)
                        }.to(change({ count.currentCount }, from: 0, to: 14))
                    }

                    it("should create assignment groups") {
                        let count = AssignmentGroup.observeCount(inSession: session)
                        let refresher = try! Assignment.refresher(session, courseID: "1867097", gradingPeriodID: nil)
                        expect {
                            refresher.playback("assignment-grades", in: currentBundle, with: session)
                        }.to(change({ count.currentCount }, from: 0, to: 3))
                    }

                    it("should link assignments to their assignment group") {
                        let assignment = Assignment.build(inSession: session) {
                            $0.id = "9599332"
                            $0.courseID = "1867097"
                            $0.assignmentGroup = nil
                        }

                        let refresher = try! Assignment.refresher(session, courseID: "1867097", gradingPeriodID: nil)
                        
                        refresher.playback("assignment-grades", in: currentBundle, with: session)
                        expect(assignment.reload().assignmentGroup?.name).to(equal("Group 1"))
                    }

                    context("with multiple grading periods") {
                        beforeEach {
                            session = User(credentials: .mgpUser1).session
                        }

                        it("should update assignment grading period id") {
                            let assignment = Assignment.build(inSession: session) {
                                $0.id = "1"
                                $0.gradingPeriodID = nil
                            }

                            let refresher = try! Assignment.refresher(session, courseID: "1", gradingPeriodID: "1")

                            refresher.playback("assignment-grades-mgp", in: currentBundle, with: session)
                            expect(assignment.reload().gradingPeriodID) == "1"
                        }
                    }
                }
            }

            describe("submissions(for:callback:)") {
                var session: Session!
                var assignment: Assignment!
                beforeEach {
                    session = .user1
                    assignment = Assignment.build(inSession: session)
                }

                it("should create a text submission for each text attachment") {
                    assignment.submissionTypes = [.text]
                    let one = NSItemProvider("foo" as NSSecureCoding?, kUTTypeText)
                    let two = NSItemProvider("bar" as NSSecureCoding?, kUTTypeText)

                    var result: Result<[NewUpload], NSError>?
                    waitUntil { done in
                        assignment.submissions(for: [one, two]) {
                            result = $0
                            done()
                        }
                    }

                    expect(result).toNot(beNil())
                    expect(result?.error).to(beNil())
                    expect(result?.value?.count) == 2
                    if let one = result?.value?.first, let two = result?.value?.last {
                        if case .text("foo") = one {} else {
                            fail("expected .Text('foo') got \(one)")
                        }
                        if case .text("bar") = two {} else {
                            fail("expected .Text('bar') got \(two)")
                        }
                    }
                }

                it("should create url submissions for url attachments") {
                    assignment.submissionTypes = [.url]
                    let one = NSItemProvider(NSURL(string: "https://google.com")!, kUTTypeURL)
                    let two = NSItemProvider(NSURL(string: "https://facebook.com")!, kUTTypeURL)

                    var result: Result<[NewUpload], NSError>?
                    waitUntil { done in
                        assignment.submissions(for: [one, two]) {
                            result = $0
                            done()
                        }
                    }
                    
                    expect(result).toNot(beNil())
                    expect(result?.error).to(beNil())
                    expect(result?.value?.count) == 2
                    if let one = result?.value?.first, let two = result?.value?.last {
                        if case .url(URL(string: "https://google.com")!) = one {} else {
                            fail("expected .URL('https://google.com') got \(one)")
                        }
                        if case .url(URL(string: "https://facebook.com")!) = two {} else {
                            fail("expected .URL('https://facebook.com') got \(two)")
                        }
                    }
                }

                it("should consolidate all file attachments into one submission") {
                    assignment.submissionTypes = [.upload]
                    let one = NSItemProvider(factoryImage, kUTTypeImage)
                    let two = NSItemProvider(NSData(), kUTTypeItem)
                    
                    var result: Result<[NewUpload], NSError>?
                    waitUntil { done in
                        assignment.submissions(for: [one, two]) {
                            result = $0
                            done()
                        }
                    }
                    
                    expect(result).toNot(beNil())
                    expect(result?.error).to(beNil())
                    expect(result?.value?.count) == 1
                    if let submission = result?.value?.first {
                        if case .fileUpload(let files) = submission {
                            expect(files.count) == 2
                        } else {
                            fail("expected a file upload")
                        }
                    }
                }

                it("should handle many attachment types") {
                    assignment.submissionTypes = [.text, .url]
                    let text = NSItemProvider("foo" as NSSecureCoding?, kUTTypeText)
                    let url = NSItemProvider(NSURL(string: "https://google.com")!, kUTTypeURL)

                    var result: Result<[NewUpload], NSError>?
                    waitUntil { done in
                        assignment.submissions(for: [text, url]) {
                            result = $0
                            done()
                        }
                    }

                    expect(result).toNot(beNil())
                    expect(result?.error).to(beNil())
                    expect(result?.value?.count) == 2
                    if let one = result?.value?.first, let two = result?.value?.last {
                        if case .text("foo") = one {} else {
                            fail("expected .Text('foo') got \(one)")
                        }
                        if case .url(URL(string: "https://google.com")!) = two {} else {
                            fail("expected .URL('https://google.com') got \(two)")
                        }
                    }
                }

                context("when one or more attachment is not supported by the assignment") {
                    it("should send an error") {
                        assignment.submissionTypes = [.url]
                        let text = NSItemProvider("foo" as NSSecureCoding?, kUTTypeText)

                        var result: Result<[NewUpload], NSError>?
                        waitUntil { done in
                            assignment.submissions(for: [text]) {
                                result = $0
                                done()
                            }
                        }
                        
                        expect(result).toNot(beNil())
                        expect(result?.value).to(beNil())
                        expect(result?.error).toNot(beNil())
                    }
                }
            }
        }
    }
}
