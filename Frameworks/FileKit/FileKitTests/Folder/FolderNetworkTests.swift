//
//  FolderNetworkTests.swift
//  FileKit
//
//  Created by Egan Anderson on 5/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
@testable import FileKit

class FolderNetworkTests: XCTestCase {
    func testDeleteFolder() {
        attempt {
            let session = Session.nas
            var response: JSONObject?
            
            stub(session, "delete-folder") { expectation in
                try Folder.deleteFolder(session, folderID: "10396915", shouldForce: true)
                    .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                    .startWithNext { json in
                        response = json
                }
            }
            XCTAssertNotNil(response)
        }
    }
    
    func testAddFolder() {
        attempt {
            let session = Session.nas
            let contextID = ContextID(id: "6782429", context: .User)
            var response: JSONObject?
            
            stub(session, "add-folder") { expectation in
                try Folder.addFolder(session, contextID: contextID, folderID: "10119415", name: "Folder")
                    .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                    .startWithNext { json in
                        response = json
                }
            }
            
            guard let json = response else {
                XCTFail("expected a response")
                return
            }
            
            let name: String? = try? json <| "name"
            XCTAssertEqual("Folder 7", name)
            let parentFolder: String? = try? json.stringID("parent_folder_id")
            XCTAssertEqual("10119415", parentFolder)
        }
    }
    
    func testGetRootFolder() {
        attempt {
            let session = Session.nas
            let contextID = ContextID(id: "6782429", context: .User)
            var response: JSONObject?
            
            stub(session, "get-root-folder") { expectation in
                try Folder.getRootFolder(session, contextID: contextID)
                    .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                    .startWithNext { json in
                        response = json
                }
            }
            
            guard let json = response else {
                XCTFail("expected a response")
                return
            }
            
            XCTAssert(json.keys.contains("id"))
            XCTAssert(json.keys.contains("name"))
            XCTAssert(json.keys.contains("hidden_for_user"))
            XCTAssert(json.keys.contains("folders_url"))
            XCTAssert(json.keys.contains("files_url"))
            XCTAssert(json.keys.contains("files_count"))
            XCTAssert(json.keys.contains("folders_count"))
            XCTAssert(json.keys.contains("parent_folder_id"))
        }
    }
    
    func testGetFolders() {
        attempt {
            let session = Session.nas
            var response: [JSONObject]?
            
            stub(session, "get-folders") { expectation in
                try Folder.getFolders(session, folderID: "9942379")
                    .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                    .startWithNext { json in
                        response = json
                }
            }
            
            guard let json = response, folder = json.first where json.count == 3 else {
                XCTFail("expected a response")
                return
            }
            
            XCTAssert(folder.keys.contains("id"))
            XCTAssert(folder.keys.contains("name"))
            XCTAssert(folder.keys.contains("hidden_for_user"))
            XCTAssert(folder.keys.contains("folders_url"))
            XCTAssert(folder.keys.contains("files_url"))
            XCTAssert(folder.keys.contains("files_count"))
            XCTAssert(folder.keys.contains("folders_count"))
            XCTAssert(folder.keys.contains("parent_folder_id"))
        }
    }
}
