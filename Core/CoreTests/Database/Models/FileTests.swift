//
// Copyright (C) 2019-present Instructure, Inc.
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
import TestsFoundation

class FileTests: CoreTestCase {
    func testSave() {
        let item = APIFile.make(["id": "1"])
        XCTAssertNoThrow(try File.save(item, in: databaseClient))
        let files: [File] = databaseClient.fetch()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.filename, item.filename)
    }

    func testIcon() {
        XCTAssertEqual(File.make([ "mimeClass": "audio" ]).icon, UIImage.icon(.audio))
        XCTAssertEqual(File.make([ "mimeClass": "video" ]).icon, UIImage.icon(.video))
        XCTAssertEqual(File.make([ "mimeClass": "pdf" ]).icon, UIImage.icon(.pdf))
        XCTAssertEqual(File.make([ "mimeClass": "doc" ]).icon, UIImage.icon(.document))
        XCTAssertEqual(File.make([ "mimeClass": "bogus" ]).icon, UIImage.icon(.document))
    }
}
