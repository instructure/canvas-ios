//
//  FileTests.swift
//  FileKit
//
//  Created by Egan Anderson on 5/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import FileKit
import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import UIKit

class FileTests: XCTestCase {
    func testIsValid() {
        attempt {
            let session = Session.inMemory
            let context = try session.filesManagedObjectContext()
            let file = File.build(context)
            XCTAssert(file.isValid)
        }
    }
    
    func testDeleteFile() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let file: File = File.build(context, contextID: ContextID(id: "6782429", context: .User), id: "85285506", name: "file")
            try context.save()
            assertDifference({ File.count(inContext: context) }, -1) {
                self.stub(session, "delete-file") { expectation in
                    try file.deleteFileNode(session, shouldForce: true)
                        .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                        .start()
                }
            }
            let results: [File] = try context.findAll(withValue: "85285506", forKey: "id")
            XCTAssert(results.isEmpty)
        }
   }
    
    func testUpdateValues() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let file = File.build(context)
            let url: NSURL = NSURL(string: "https://mobiledev.instructure.com/files/83591766/download?download_frd=1&verifier=K0bbFrCr8lh1t3LF9H1ffioCUnNJKgpQTJe2kzZ9")!
            let json: [String: AnyObject] = [
                "id": "1",
                "display_name": "Steve",
                "hidden_for_user": false,
                "content-type": "pdf",
                "thumbnail_url": "https://mobiledev.instructure.com/files/83591766/download?download_frd=1&verifier=K0bbFrCr8lh1t3LF9H1ffioCUnNJKgpQTJe2kzZ9",
                "url": "https://mobiledev.instructure.com/files/83591766/download?download_frd=1&verifier=K0bbFrCr8lh1t3LF9H1ffioCUnNJKgpQTJe2kzZ9",
                "size": 10
            ]
            try file.updateValues(json, inContext: context)
            XCTAssertEqual("1", file.id)
            XCTAssertEqual("Steve", file.name)
            XCTAssertFalse(file.hiddenForUser)
            XCTAssertFalse(file.isFolder)
            XCTAssertEqual("pdf", file.contentType)
            XCTAssertEqual(url, file.thumbnailURL)
            XCTAssertEqual(url, file.url)
            XCTAssertEqual(10, file.size)
        }
    }
    
    func testContextID() {
        attempt {
            let session = Session.inMemory
            let context = try session.filesManagedObjectContext()
            let file = File.build(context)
            let rawContextID: String = "user_6782429"
            let contextID: ContextID = ContextID(canvasContext: rawContextID)!
            file.contextID = contextID
            XCTAssertEqual(contextID, file.contextID)
        }
    }
    
    func testIcon() {
        attempt {
            let session = Session.inMemory
            let context = try session.filesManagedObjectContext()
            let file = File.build(context)
            file.contentType = "image/jpeg"
            var image = file.icon
            XCTAssert(file.iconName == "icon_image")
            file.contentType = "video/quicktime"
            image = file.icon
            XCTAssert(file.iconName == "icon_video_clip")
            file.contentType = "text/x-java"
            image = file.icon
            XCTAssert(file.iconName == "icon_page")
            file.contentType = "application/pdf"
            image = file.icon
            XCTAssert(file.iconName == "icon_pdf")
            file.contentType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            file.name = "title.doc"
            image = file.icon
            XCTAssert(file.iconName == "icon_page")
            file.contentType = "application/zip"
            image = file.icon
            XCTAssert(file.iconName == "icon_document")
            file.lockedForUser = true
            image = file.icon
            XCTAssert(file.iconName == "icon_locked")
        }
    }
}
