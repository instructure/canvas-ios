//
//  FileUploadTests.swift
//  FileKit
//
//  Created by Nathan Armstrong on 4/12/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
@testable import FileKit
import CoreData
import ReactiveCocoa
import DoNotShipThis
import TooLegit
import AVFoundation
import SoPersistent

class FileUploadTests: XCTestCase {
    let session = Session.nas
    var context: NSManagedObjectContext!
    var upload: FileUpload!

    override func setUp() {
        super.setUp()
        let data = NSData(contentsOfURL: NSBundle(forClass: FileUploadTests.self).URLForResource("testfile", withExtension: "txt")!)!
        let parentFolderID = "6782429"
        let path = "/api/v1/users/\(parentFolderID)/files"

        context = try! session.fileKitTestsManagedObjectContext()
        upload = FileUpload.createInContext(context)
        upload.prepare("unit test", path: path, data: data, name: "testfile.txt", contentType: nil, parentFolderID: parentFolderID, contextID: ContextID(id: parentFolderID, context: .User))

        XCTAssert(upload.isValid)
    }
    
    func testUploadingAFileCreatesAFileLocally() {
        let backgroundSession = session.copyToBackgroundSessionWithIdentifier("unit test", sharedContainerIdentifier: nil)
        let predicate = NSPredicate(format: "%K == %@", "backgroundSessionID", "unit test")
        let observer = try! ManagedObjectObserver<FileUpload>(predicate: predicate, inContext: context)
        var disposable = Disposable?()
        
        stub(backgroundSession, "upload-file") { expectation in
            disposable = observer.signal.observeNext { _, object in
                guard let upload = object else { return }
                if let error = upload.errorMessage {
                    XCTFail(error)
                    return
                }
                if upload.hasCompleted {
                    expectation.fulfill()
                }
            }
            self.upload.begin(inSession: backgroundSession, inContext: self.context)
        }

        disposable?.dispose()
    }
    
    func testCancel() {
        attempt {
            setUp()
            let data = NSData(contentsOfURL: NSBundle(forClass: FileUploadTests.self).URLForResource("testfile", withExtension: "txt")!)!
            let path = "/api/v1/courses/24219/assignments/7214701/submissions/self/files"
            let request = try session.requestPostUploadTarget(path, fileName: "name", size: data.length, contentType: "file", folderPath: nil, overwrite: false)
            let task = session.URLSession.dataTaskWithRequest(request)
            upload.startWithTask(task)
            upload.cancel()
            XCTAssert(upload.terminatedAt != nil)
            XCTAssert(upload.canceledAt != nil)
        }
    }
    
    func testFailWithError() {
        attempt {
            setUp()
            let error: NSError = NSError(domain: "domain", code: 123, userInfo: nil)
            let data = NSData(contentsOfURL: NSBundle(forClass: FileUploadTests.self).URLForResource("testfile", withExtension: "txt")!)!
            let path = "/api/v1/courses/24219/assignments/7214701/submissions/self/files"
            let request = try session.requestPostUploadTarget(path, fileName: "name", size: data.length, contentType: "file", folderPath: nil, overwrite: false)
            let task = session.URLSession.dataTaskWithRequest(request)
            upload.startWithTask(task)
            upload.failWithError(error)
            XCTAssert(upload.terminatedAt != nil)
            XCTAssert(upload.failedAt != nil)
            XCTAssert(upload.errorMessage != nil)
        }
    }
    
    func testPrepare() {
        setUp()
        let data = NSData(contentsOfURL: NSBundle(forClass: FileUploadTests.self).URLForResource("testfile", withExtension: "txt")!)!
        let path = "/api/v1/courses/24219/assignments/7214701/submissions/self/files"
        upload.prepare("id", path: path, data: data, name: "file", contentType: "image", parentFolderID: nil, contextID: ContextID(id: "24219", context: .Course))
        XCTAssertEqual(data, upload.data)
        XCTAssertEqual(path, upload.path)
        XCTAssertEqual("file", upload.name)
        XCTAssertEqual("image", upload.contentType)
        XCTAssertEqual("id", upload.backgroundSessionID)
    }
}
