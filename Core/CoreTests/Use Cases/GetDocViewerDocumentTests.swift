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
@testable import Core
import TestsFoundation

class GetDocViewerDocumentTest: CoreTestCase {
    func testExecuteCancelled() {
        let api = MockAPI()
        let getDoc = GetDocViewerDocument(api: api, downloadURL: URL(string: "download")!)
        getDoc.cancel()
        getDoc.execute()
        XCTAssertNil(getDoc.localURL)
    }

    func testExecute() {
        let api = MockAPI()
        let url = URL(string: "download")!
        let temp = Bundle(for: GetDocViewerDocumentTest.self).url(forResource: "TestImage", withExtension: "png")!
        let getDoc = GetDocViewerDocument(api: api, downloadURL: url)
        api.mockDownload(url, value: temp, response: nil, error: nil)
        getDoc.execute()
        XCTAssertNotNil(getDoc.localURL)
        XCTAssertNoThrow(try FileManager.default.removeItem(at: getDoc.localURL!))
    }

    func testExecuteError() {
        let api = MockAPI()
        let url = URL(string: "download")!
        let temp = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("\(UUID().uuidString).pdf")
        let getDoc = GetDocViewerDocument(api: api, downloadURL: url)
        api.mockDownload(url, value: temp, response: nil, error: APIDocViewerError.noData)
        getDoc.execute()
        XCTAssertEqual(getDoc.errors.count, 2)
    }
}
