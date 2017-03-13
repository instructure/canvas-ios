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

import UIKit
import XCTest

class CKIFolderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testJSONModelConversion() {
        
        let folderDictionary = Helpers.loadJSONFixture("folder") as NSDictionary
        let folder = CKIFolder(fromJSONDictionary: folderDictionary)
        
        XCTAssertEqual(folder.contextType!, "Course", "Folder contextType did not parse correctly")
        XCTAssertEqual(folder.contextID!, "1401", "Folder contextID did not parse correctly")
        XCTAssertEqual(folder.filesCount, 10, "Folder filesCount did not parse correctly")
        XCTAssertEqual(folder.foldersCount, 0, "Folder foldersCount did not parse correctly")
        
        var url = NSURL(string:"https://www.example.com/api/v1/folders/2937/folders")
        XCTAssertEqual(folder.foldersURL!, url!, "Folder foldersURL did not parse correctly")
        url = NSURL(string:"https://www.example.com/api/v1/folders/2937/files")
        XCTAssertEqual(folder.filesURL!, url!, "Folder filesURL did not parse correctly")
        
        let formatter = ISO8601DateFormatter()
        formatter.includeTime = true
        let date = formatter.dateFromString("2012-07-06T14:58:50Z")
        XCTAssertEqual(folder.createdAt!, date, "Folder createdAt did not parse correctly")
        XCTAssertEqual(folder.updatedAt!, date, "Folder updatedAt did not parse correctly")
        XCTAssertEqual(folder.unlockAt!, date, "Folder unlockAt did not parse correctly")

        XCTAssertEqual(folder.id!, "2937", "Folder id did not parse correctly")
        XCTAssertEqual(folder.name!, "11folder", "Folder name did not parse correctly")
        XCTAssertEqual(folder.fullName!, "course files/11folder", "Folder fullName did not parse correctly")
        XCTAssertEqual(folder.lockAt!, date, "Folder lockAt did not parse correctly")
        XCTAssertEqual(folder.parentFolderID!, "2934", "Folder parentFolderID did not parse correctly")
        XCTAssertFalse(folder.hiddenForUser, "Folder hiddenForUser did not parse correctly")
        XCTAssertEqual(folder.position, 3, "Folder position did not parse correctly")
        XCTAssertEqual(folder.path!, "/api/v1/folders/2937", "Folder path did not parse correctly")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
