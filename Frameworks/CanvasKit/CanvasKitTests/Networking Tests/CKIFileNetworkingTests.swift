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

import XCTest

class CKIFileNetworkingTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFetchFile() {
        let client = MockCKIClient()
        let fileID = "569"
        
        client.fetchFile(fileID)
        XCTAssertEqual(client.capturedPath!, "/api/v1/files/569", "CKIFile returned API path for testFetchFile was incorrect")
    }
    
    func testDeleteFile() {
        let fileDictionary = Helpers.loadJSONFixture("file") as NSDictionary
        let file = CKIFile(fromJSONDictionary: fileDictionary)
        let client = MockCKIClient()
        
        client.deleteFile(file)
        XCTAssertEqual(client.capturedPath!, "/api/v1/files/569", "CKIFile returned API path for testDeleteFile was incorrect")
    }
    
    func testUploadFile() {
        let folderDictionary = Helpers.loadJSONFixture("folder") as NSDictionary
        let folder = CKIFolder(fromJSONDictionary: folderDictionary)
        let client = MockCKIClient()
        
        client.uploadFile(nil, ofType: "jpg", withName: "test", inFolder: folder)
        //TODO figure out how to capture the path by possibly overloading the fileUploadTokenSignalForPath method. Currently not possible.
    }
}
