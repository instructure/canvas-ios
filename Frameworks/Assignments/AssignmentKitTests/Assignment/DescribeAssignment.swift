//
//  AssignmentTests.swift
//  Assignments
//
//  Created by Nathan Armstrong on 3/16/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
@testable import AssignmentKit
import SoAutomated
import CoreData
import Marshal
import SoPersistent
import TooLegit
import FileKit

class DescribeAssignment: XCTestCase {
    let session = Session.nas
    var assignment: Assignment!
    var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        context = try! session.assignmentsManagedObjectContext()
        assignment = Assignment.build(context)
    }

    func test_isValid() {
        XCTAssert(assignment.isValid)
    }
}

class DescribeAssignmentGrade: XCTestCase {
    let session = Session.inMemory
    var assignment: Assignment!

    override func setUp() {
        super.setUp()
        let context = try! session.assignmentsManagedObjectContext()
        assignment = Assignment.build(context)
    }

    func testNotGraded() {
        assignment.gradingType = .NotGraded
        XCTAssertEqual("n/a", assignment.grade)
    }

    func testLetterGrade() {
        assignment.gradingType = .LetterGrade
        assignment.currentGrade = "A-"
        XCTAssertEqual("A-", assignment.grade)
    }

    func testLetterGrade_whenCurrentGradeIsEmpty() {
        assignment.gradingType = .LetterGrade
        assignment.currentGrade = ""
        XCTAssertEqual("-", assignment.grade)
    }

    func testGPAScale() {
        assignment.gradingType = .GPAScale
        assignment.currentGrade = "3.7"
        XCTAssertEqual("3.7", assignment.grade)
    }

    func testGPAScale_whenCurrentGradeIsEmpty() {
        assignment.gradingType = .GPAScale
        assignment.currentGrade = ""
        XCTAssertEqual("-", assignment.grade)
    }

    func testPassFail() {
        assignment.gradingType = .PassFail
        assignment.currentGrade = "P"
        XCTAssertEqual("P", assignment.grade)
    }

    func testPassFail_whenCurrentGradeIsEmpty() {
        assignment.gradingType = .PassFail
        assignment.currentGrade = ""
        XCTAssertEqual("-", assignment.grade)
    }

    func testPercent() {
        assignment.gradingType = .Percent
        assignment.currentGrade = "90%"
        XCTAssertEqual("90%", assignment.grade)
    }

    func testPercent_whenCurrentGradeIsEmpty() {
        assignment.gradingType = .Percent
        assignment.currentGrade = ""
        XCTAssertEqual("-", assignment.grade)
    }

    func testPoints() {
        assignment.gradingType = .Points
        assignment.currentGrade = "86"
        assignment.pointsPossible = 100
        XCTAssertEqual("86/100", assignment.grade)
    }

    func testPoints_whenCurrentGradeIsEmpty() {
        assignment.gradingType = .Points
        assignment.currentGrade = ""
        assignment.pointsPossible = 100
        XCTAssertEqual("-/100", assignment.grade)
    }

    func testPoints_whenCurrentGradeIsNotANumber() {
        assignment.gradingType = .Points
        assignment.currentGrade = "oops"
        assignment.pointsPossible = 40
        XCTAssertEqual("-/40", assignment.grade)
    }
}

class DescribeUploadForNewSubmission: DescribeAssignment {
    func test_itCreatesATextSubmissionUpload() {
        let newSubmission = NewUpload.Text("this is some text")
        try! assignment.uploadForNewSubmission(newSubmission, inSession: session) { upload in
            guard upload != nil else {
                XCTFail("upload is nil")
                return
            }

            guard let upload = upload as? TextSubmissionUpload else {
                XCTFail("upload should be a text upload")
                return
            }

            XCTAssert(upload.isValid)
            XCTAssertEqual("this is some text", upload.text)
            XCTAssertEqual(self.assignment, upload.assignment)
        }
    }

    func test_itCreatesAURLSubmissionUpload() {
        let newSubmission = NewUpload.URL(NSURL(string: "http://google.com")!)
        try! assignment.uploadForNewSubmission(newSubmission, inSession: session) { upload in
            guard upload != nil else {
                XCTFail("upload is nil")
                return
            }

            guard let upload = upload as? URLSubmissionUpload else {
                XCTFail("upload should be a url upload")
                return
            }

            XCTAssert(upload.isValid)
            XCTAssertEqual("http://google.com", upload.url)
            XCTAssertEqual(self.assignment, upload.assignment)
        }
    }

    func test_itCreatesAFileSubmissionUpload() {
        let file = NewUploadFile.FileURL(factoryURL)
        let image = NewUploadFile.Photo(factoryImage)
        let newSubmission = NewUpload.FileUpload([file, image])

        try! assignment.uploadForNewSubmission(newSubmission, inSession: session) { upload in
            guard upload != nil else {
                XCTFail("upload is nil")
                return
            }

            guard let upload = upload as? FileSubmissionUpload else {
                XCTFail("upload should be a file upload")
                return
            }

            func inspectFileUpload(upload: SubmissionFileUpload) {
                XCTAssert(upload.isValid)
                XCTAssertEqual("testfile.txt", upload.name)
                XCTAssertEqual("text/plain", upload.contentType)
                XCTAssertNotNil(upload.data)
            }

            func inspectImageUpload(upload: SubmissionFileUpload) {
                XCTAssert(upload.isValid)
                XCTAssertEqual("Photo", upload.name)
                XCTAssertEqual("image/jpeg", upload.contentType)
                XCTAssertNotNil(upload.data)
            }

            XCTAssert(upload.isValid)
            XCTAssertEqual(2, upload.fileUploads.count)
            let fileUploads: (String, String) = (upload.fileUploads.first?.name ?? "", Array(upload.fileUploads).last?.name ?? "")
            switch fileUploads {
            case ("", ""), (_, ""), ("", _): XCTFail("one or both file upload names are blank")
            case ("testfile.txt", "Photo"):
                inspectFileUpload(upload.fileUploads.first!)
                inspectImageUpload(Array(upload.fileUploads).last!)
            case ("Photo", "testfile.txt"):
                inspectImageUpload(upload.fileUploads.first!)
                inspectFileUpload(Array(upload.fileUploads).last!)
            default: XCTFail("failed to match on file uploads")
            }
        }
    }
}

class DescribeDeterminingIfAnUploadBackgroundSessionExists: DescribeAssignment {
    func test_itDoesExist() {
        let upload = TextSubmissionUpload.create(backgroundSessionID: assignment.submissionUploadIdentifier, assignment: assignment, text: "", inContext: context)
        upload.startWithTask(DummyTask())
        try! context.save() // Must save context to persistent store before using NSDictionaryResultType

        XCTAssert(assignment.uploadBackgroundSessionExists(session))
    }

    func test_itDoesNotExist() {
        XCTAssertFalse(assignment.uploadBackgroundSessionExists(session))
    }
}
