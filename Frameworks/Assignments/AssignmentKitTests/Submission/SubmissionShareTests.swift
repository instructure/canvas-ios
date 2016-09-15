//
//  SubmissionShareTests.swift
//  Assignments
//
//  Created by Nathan Armstrong on 3/18/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import Foundation
@testable import AssignmentKit
import SoAutomated
import MobileCoreServices
import Result
import ReactiveCocoa
import TooLegit
import DoNotShipThis
import FileKit
import UIKit

class SubmissionShareTests: XCTestCase {

    var session = Session.nas
    var context = TestSubmissionExtensionContext()
    var extensionItem = TestSubmissionExtensionItem()
    var assignment: Assignment!
    var submissionBuilder: ShareSubmissionBuilder!

    override func setUp() {
        super.setUp()
        context.submissionInputItems = [extensionItem]
        let managedObjectContext = try! session.assignmentsManagedObjectContext()
        assignment = Assignment.build(managedObjectContext,
                                      submissionTypes: [.Upload, .Text, .URL, .MediaRecording],
                                      allowedExtensions: nil)
        submissionBuilder = ShareSubmissionBuilder(assignment: assignment)
    }

    func test_itConvertsTextAttachmentToTextSubmission() {
        let textAttachment = Attachment("blurb", kUTTypeText)
        addItemAttachment(textAttachment)
        var newSubmission: NewUpload?
        let expectation = expectationWithDescription("it creates a text submission")

        let disposable = submissionBuilder.submissionsForExtensionContext(context)
            .startWithNext { submission in
                newSubmission = submission
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(2, handler: nil)
        guard let submission = newSubmission else {
            XCTFail("value should not be nil")
            return
        }
        var text: String?
        if case .Text(let t) = submission {
            text = t
        }
        XCTAssertEqual("blurb", text)
        disposable.dispose()
    }

    func test_itConvertsURLAttachmentToURLSubmission() {
        let urlAttachment = Attachment(NSURL(string: "https://google.com")!, kUTTypeURL)
        addItemAttachment(urlAttachment)
        var newSubmission: NewUpload?
        let expectation = expectationWithDescription("it creates a url submission")

        let disposable = submissionBuilder.submissionsForExtensionContext(context)
            .startWithNext { submission in
                newSubmission = submission
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(2, handler: nil)
        guard let submission = newSubmission else {
            XCTFail("value should not be nil")
            return
        }
        var url: NSURL?
        if case .URL(let u) = submission {
            url = u
        }
        XCTAssertEqual("https://google.com", url?.absoluteString)
        disposable.dispose()
    }

    func test_itConvertsPhotoAttachmentToPhotoSubmission() {
        let attachment = Attachment(factoryImage, kUTTypeImage)
        addItemAttachment(attachment)
        var newSubmission: NewUpload?
        let expectation = expectationWithDescription("it creates an image submission")

        let disposable = submissionBuilder.submissionsForExtensionContext(context)
            .startWithNext { submission in
                newSubmission = submission
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(2, handler: nil)
        guard let submission = newSubmission else {
            XCTFail("value should not be nil")
            return
        }

        var photo: UIImage?
        if case .FileUpload(let files) = submission {
            guard let file = files.first else {
                XCTFail("expected a file")
                return
            }
            if case .Photo(let p) = file {
                photo = p
            } else {
                XCTFail("expected Photo got \(file)")
            }
        } else {
            XCTFail("expected FileUpload got \(submission)")
        }
        XCTAssertNotNil(photo)
        disposable.dispose()
    }

    func test_itConvertsItemAttachmentToDataSubmission() {
        let imageData = getFactoryImageData()
        let attachment = Attachment(imageData, kUTTypeItem)
        addItemAttachment(attachment)
        var newSubmission: NewUpload?
        let expectation = expectationWithDescription("it creates a data submission")

        let disposable = submissionBuilder.submissionsForExtensionContext(context)
            .startWithNext { submission in
                newSubmission = submission
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(2, handler: nil)
        guard let submission = newSubmission else {
            XCTFail("value should not be nil")
            return
        }

        var data: NSData?
        if case .FileUpload(let files) = submission {
            guard let file = files.first else {
                XCTFail("expected a file")
                return
            }
            if case .Data(let d) = file {
                data = d
            } else {
                XCTFail("expected Data got \(file)")
            }
        } else {
            XCTFail("expected FileUpload got \(submission)")
        }
        guard let d = data else {
            XCTFail("data should not be nil")
            return
        }
        XCTAssert(d.isEqualToData(imageData))
        disposable.dispose()
    }

    func test_itConvertsMultipleTextAttachmentsToMultipleTextSubmissions() {
        addItemAttachment(Attachment("one", kUTTypeText))
        addItemAttachment(Attachment("two", kUTTypeText))
        var newSubmissions = [NewUpload]()
        let expectation = expectationWithDescription("it creates to attachments")

        let disposable = submissionBuilder.submissionsForExtensionContext(context)
            .startWithNext { submission in
                newSubmissions.append(submission)
                if newSubmissions.count >= 2 {
                    expectation.fulfill()
                }
            }

        waitForExpectationsWithTimeout(2, handler: nil)
        XCTAssertEqual(2, newSubmissions.count)
        switch (newSubmissions[0], newSubmissions[1]) {
        case (.Text("one"), .Text("two")), (.Text("two"), .Text("one")):
            break // it passed
        default: XCTFail("unexpected submissions \(newSubmissions[0]), \(newSubmissions[1])")
        }
        disposable.dispose()
    }

    func test_itConvertsMultipleFileAttachmentsToASingleFileSubmission() {
        let one = factoryImage
        let two = getFactoryImageData()
        addItemAttachment(Attachment(one, kUTTypeImage))
        addItemAttachment(Attachment(two, kUTTypeItem))
        var newSubmission: NewUpload?
        let expectation = expectationWithDescription("it creates file submission")

        let disposable = submissionBuilder.submissionsForExtensionContext(context)
            .startWithNext { submission in
                newSubmission = submission
                expectation.fulfill()
            }

        waitForExpectationsWithTimeout(2, handler: nil)
        guard let submission = newSubmission else {
            XCTFail("submission should not be nil")
            return
        }

        if case .FileUpload(let files) = submission {
            XCTAssertEqual(2, files.count)
            if let first = files.first, last = files.last {
                if case .Photo(_) = first {} else { XCTFail("expected a photo got \(first)") }
                if case .Data(_) = last {} else { XCTFail("expected data got \(last)") }
            } else {
                XCTFail("expected two files")
            }
        } else {
            XCTFail("expected FileUpload got \(submission)")
        }
        disposable.dispose()
    }

    func addItemAttachment(attachment: Attachment) {
        extensionItem.submissionAttachments.append(attachment)
    }

    func getFactoryImageData() -> NSData {
        let bundle = NSBundle(forClass: SubmissionShareTests.self)
        let path = bundle.pathForResource("hubble-large", ofType: "jpg")!
        return NSData(contentsOfFile: path)!
    }

}

// MARK: - Types

class TestSubmissionExtensionContext: SubmissionExtensionContext {
    @objc var submissionInputItems = [SubmissionExtensionItem]()
}

class TestSubmissionExtensionItem: SubmissionExtensionItem {
    @objc var submissionAttachments = [Attachment]()
}

extension Attachment {
    convenience init(_ item: NSSecureCoding?, _ identifier: CFString) {
        self.init(item: item, typeIdentifier: identifier as String)
    }
}
