//
//  FolderTests.swift
//  FileKit
//
//  Created by Egan Anderson on 5/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

@testable import FileKit
import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal

class FolderTests: XCTestCase {
    func testIsValid() {
        attempt {
            let session = Session.inMemory
            let context = try session.filesManagedObjectContext()
            let folder = Folder.build(context)
            XCTAssert(folder.isValid)
        }
    }
    
    func testDeleteFileNode() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let folder = Folder.build(context, id: "10396915")
            
            assertDifference({ Folder.count(inContext: context) }, -1) {
                self.stub(session, "delete-folder") { expectation in
                    try folder.deleteFileNode(session, shouldForce: true)
                        .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                        .start()
                }
            }
            
            let results: [Folder] = try context.findAll(withValue: "10396915", forKey: "id")
            XCTAssert(results.isEmpty)
        }
    }
    
    func testNewFolder() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let contextID = ContextID(id: "6782429", context: .User)
            
            assertDifference({ Folder.count(inContext: context) }, 1) {
                self.stub(session, "add-folder") { expectation in
                    Folder.newFolder(session, contextID: contextID, folderID: "10119415", name: "Folder")
                        .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                        .start()
                }
            }
            
            guard let folder: Folder = try context.findOne(withValue: "10119415", forKey: "parentFolderID") else {
                XCTFail("Expected a folder")
                return
            }
            
            XCTAssertEqual("Folder 7", folder.name)
        }
    }
    
    func testCreate() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let contextID = ContextID(id: "6782429", context: .User)
            
            let folder: Folder = Folder.create(inContext: context, contextID: contextID)
            XCTAssertEqual(contextID.canvasContextID, folder.rawContextID)
        }
   }
    
    func testUpdateValues() {
        attempt {
            let session = Session.nas
            let context = try session.filesManagedObjectContext()
            let folder = Folder.build(context)
            let url: NSURL = NSURL(string: "https://mobiledev.instructure.com/api/v1/folders/10017868/folders")!
            let json: [String: AnyObject] = [
                "id": "1",
                "name": "Steve",
                "hidden_for_user": false,
                "files_url": "https://mobiledev.instructure.com/api/v1/folders/10017868/folders",
                "folders_url": "https://mobiledev.instructure.com/api/v1/folders/10017868/folders",
                "files_count": 10,
                "folders_count": 10
            ]
            try folder.updateValues(json, inContext: context)
            XCTAssertEqual("1", folder.id)
            XCTAssertEqual("Steve", folder.name)
            XCTAssertFalse(folder.hiddenForUser)
            XCTAssertTrue(folder.isFolder)
            XCTAssertEqual(url, folder.filesUrl)
            XCTAssertEqual(url, folder.foldersUrl)
            XCTAssertEqual(10, folder.filesCount)
            XCTAssertEqual(10, folder.foldersCount)
        }
    }
}
