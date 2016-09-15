//
//  FileNetworkTests.swift
//  FileKit
//
//  Created by Egan Anderson on 5/23/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

import XCTest
import SoAutomated
import TooLegit
import DoNotShipThis
import Marshal
@testable import FileKit

class FileNetworkTests: XCTestCase {

    func testDeleteFile() {
        attempt {
            let session = Session.nas
            var response: JSONObject?
            stub(session, "delete-file") { expectation in
                try File.deleteFile(session, fileID: "85285506")
                    .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                    .startWithNext { json in
                        response = json
                }
            }
            XCTAssertNotNil(response)
        }
    }
    
    func testGetFiles() {
        attempt {
            let session = Session.nas
            var response: [JSONObject]?
            
            stub(session, "get-files", timeout: 10) { expectation in
                try File.getFiles(session, folderID: "10119415")
                    .on(failed: { XCTFail($0.localizedDescription) }, completed: { expectation.fulfill() })
                    .startWithNext { json in
                        response = json
                }
            }
            
            guard let json = response, file = json.first else {
                XCTFail("expected a response")
                return
            }
            
            XCTAssert(file.keys.contains("id"))
            XCTAssert(file.keys.contains("display_name"))
            XCTAssert(file.keys.contains("hidden_for_user"))
            XCTAssert(file.keys.contains("url"))
            XCTAssert(file.keys.contains("size"))
            XCTAssert(file.keys.contains("locked_for_user"))
            XCTAssert(file.keys.contains("thumbnail_url"))
        }
   }
}
