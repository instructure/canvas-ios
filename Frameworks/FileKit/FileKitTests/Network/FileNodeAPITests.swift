//
//  FileNodeAPITests.swift
//  FileKit
//
//  Created by Egan Anderson on 5/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import FileKit
import Marshal

class FileNodeAPITests: XCTestCase {
    func testDeleteFolder() {
        attempt {
            let session = Session.art
            
            var request = try FileNodeAPI.deleteFolder(session, folderID: "1", shouldForce: true)
    
            XCTAssertEqual("/api/v1/folders/1", request.URL?.relativePath, "url matches")
            XCTAssertEqual("DELETE", request.HTTPMethod, "it is a DELETE request")
            XCTAssertNotNil(request.URL?.absoluteString?.rangeOfString("force"))
            request = try FileNodeAPI.deleteFolder(session, folderID: "1", shouldForce: false)
            XCTAssertNil(request.URL?.absoluteString?.rangeOfString("force"))
        }
    }
    
    func testAddFolder() {
        attempt {
            let session = Session.art
            let contextID = ContextID(id: "1", context: .User)
            
            let request = try FileNodeAPI.addFolder(session, contextID: contextID, folderID: "1", name: "Folder")
            XCTAssertEqual("/api/v1/users/1/folders", request.URL?.relativePath, "url matches")
            XCTAssertEqual("POST", request.HTTPMethod, "it is a POST request")
            guard let body = request.HTTPBody, let d = (try? NSJSONSerialization.JSONObjectWithData(body, options: [])) as? [String: String] else {
                XCTFail("Unexpected request body")
                return
            }
            XCTAssertEqual("Folder", d["name"])
            XCTAssertEqual("1", d["parent_folder_id"])
        }
    }
    
    func testDeleteFile() {
        attempt {
            let session = Session.art
            
            let request = try FileNodeAPI.deleteFile(session, fileID: "1")
            
            XCTAssertEqual("/api/v1/files/1", request.URL?.relativePath, "url matches")
            XCTAssertEqual("DELETE", request.HTTPMethod, "it is a DELETE request")
        }
    }
    
    func testGetFiles() {
        attempt {
            let session = Session.art
            
            let request = try FileNodeAPI.getFiles(session, folderID: "1")
            
            XCTAssertEqual("/api/v1/folders/1/files", request.URL?.relativePath, "url matches")
            XCTAssertEqual("GET", request.HTTPMethod, "it is a GET request")
        }
    }
    
    func testGetRootFolder() {
        attempt {
            let session = Session.art
            
            let request = try FileNodeAPI.getRootFolder(session, contextID: ContextID(id: "1", context: .User))
            
            XCTAssertEqual("/api/v1/users/1/folders/by_path", request.URL?.relativePath, "url matches")
            XCTAssertEqual("GET", request.HTTPMethod, "it is a GET request")
        }
    }
    
    func testGetFolders() {
        attempt {
            let session = Session.art
            
            let request = try FileNodeAPI.getFolders(session, folderID: "1")
            
            XCTAssertEqual("/api/v1/folders/1/folders", request.URL?.relativePath, "url matches")
            XCTAssertEqual("GET", request.HTTPMethod, "it is a GET request")
        }
   }
}
