//
// Copyright (C) 2018-present Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

let coreTestBundle = Bundle(for: DownloadFileTest.self)

class DownloadFileTest: CoreTestCase {
    var fileURL: URL!

    override func setUp() {
        super.setUp()
        do {
            guard let resourcePath = coreTestBundle.resourcePath else {
                return
            }
            let url = URL(fileURLWithPath: resourcePath).appendingPathComponent("TestImage.png")
            fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("TestImage.png")
            if FileManager.default.fileExists(atPath: fileURL.path) == false {
                try FileManager.default.copyItem(at: url, to: fileURL)
                XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
            }
        } catch {
            XCTFail()
        }
    }

    func testDownloadFile() {
        let downloadURL = URL(string: "https://canvas.instructure.com/files/2/download")!
        File.make([
            "id": "2",
            "url": downloadURL,
        ])
        api.mockDownload(downloadURL, value: fileURL, response: nil, error: nil)

        let downloadOp = DownloadFile(fileID: "2", userID: "1", env: environment)
        addOperationAndWait(downloadOp)

        guard let file: File = databaseClient.fetch().first else {
            XCTFail()
            return
        }
        databaseClient.refresh()
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.localFileURL!.path))
    }
}
