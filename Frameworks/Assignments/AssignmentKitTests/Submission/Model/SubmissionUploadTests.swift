//
//  SubmissionUploadTests.swift
//  Assignments
//
//  Created by Nathan Armstrong on 4/6/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
@testable import AssignmentKit
import SoAutomated
import CoreData
import SoPersistent
import SoLazy
import FileKit
import ReactiveCocoa
import TooLegit

class DescribeSubmissionUploads: XCTestCase {
    let session = Session.nas
    var context: NSManagedObjectContext!
    var assignment: Assignment!

    override func setUp() {
        super.setUp()
        context = try! session.assignmentsManagedObjectContext()
        assignment = Assignment.build(context, id: "1252468", courseID: "24219")
    }
}

class DescribeTextSubmissions: DescribeSubmissionUploads {
    var upload: TextSubmissionUpload!

    override func setUp() {
        super.setUp()
        upload = TextSubmissionUpload.create(backgroundSessionID: "unit test", assignment: assignment, text: "This is some text", inContext: context)
        XCTAssert(upload.isValid)
    }

    func test_itCreatesATextSubmission() {
        var submission: Submission?
        stub(session, "upload-text-submission") { expectation in
            self.upload.rac_valuesForKeyPath("submission", observer: nil)
                .toSignalProducer()
                .map { $0 as? Submission }
                .filter { $0 != nil }
                .startWithNext {
                    submission = $0
                    expectation.fulfill()
                }
            self.upload.begin(inSession: self.session, inContext: self.context)
        }
        XCTAssertNotNil(submission)
    }
}

class DescribeURLSubmission: DescribeSubmissionUploads {
    var upload: URLSubmissionUpload!

    override func setUp() {
        super.setUp()
        upload = URLSubmissionUpload.create(backgroundSessionID: "unit test", assignment: assignment, url: "http://google.com", inContext: context)
        XCTAssert(upload.isValid)
    }

    func test_itCreatesAURLSubmission() {
        var submission: Submission?

        stub(session, "upload-url-submission") { expectation in
            self.upload.rac_valuesForKeyPath("submission", observer: nil)
                .toSignalProducer()
                .map { $0 as? Submission }
                .filter { $0 != nil }
                .startWithNext {
                    submission = $0
                    expectation.fulfill()
                }
            self.upload.begin(inSession: self.session, inContext: self.context)
        }

        XCTAssertNotNil(submission)
    }

}

class DescribeFileSubmission: DescribeSubmissionUploads {
    let backgroundSessionID = "unit test"
    
    var upload: FileSubmissionUpload!
    lazy var observer: ManagedObjectObserver<FileSubmissionUpload> = {
        let predicate = NSPredicate(format: "%K == %@ && %K == %@", "backgroundSessionID", self.backgroundSessionID, "assignment", self.assignment)
        var observer: ManagedObjectObserver<FileSubmissionUpload>!
        self.attempt {
            observer = try ManagedObjectObserver(predicate: predicate, inContext: self.context)
        }
        return observer
    }()
    
    override func setUp() {
        super.setUp()
        let data = NSData(contentsOfURL: factoryURL)!
        let path = "/api/v1/courses/24219/assignments/1252468/submissions/self/files"
        
        let fileUpload = SubmissionFileUpload(inContext: context)
        fileUpload.prepare("unit test", path: path, data: data, name: "testfile.txt", contentType: nil, parentFolderID: nil, contextID: ContextID(id: "24219", context: .Course))
        upload = FileSubmissionUpload.create(backgroundSessionID: "unit test", assignment: assignment, fileUploads: [fileUpload], comment: nil, inContext: context)
        XCTAssert(fileUpload.isValid)
    }
    
    func test_itCreatesAFileSubmission() {
        var submission: Submission?
        
        stub(session, "upload-file-submission", timeout: 4) { expectation in
            let completed = false
            self.observer.signal.observeNext { _, upload in
                submission = upload?.submission
                if submission != nil && !completed {
                    expectation.fulfill()
                }
            }
            self.upload.begin(inSession: self.session, inContext: self.context)
        }
        
        XCTAssertNotNil(submission)
    }
    
    func test_itFinishesFileUploads() {
        stub(session, "upload-file-submission", timeout: 4) { expectation in
            let completed = false
            self.observer.signal.observeNext { _, upload in
                if upload?.completedAt != nil && !completed {
                    expectation.fulfill()
                }
            }
            self.upload.begin(inSession: self.session, inContext: self.context)
        }
        
        guard let fileUpload = upload.fileUploads.first else {
            XCTFail("expected a file upload")
            return
        }
        XCTAssert(fileUpload.hasCompleted)
    }
}