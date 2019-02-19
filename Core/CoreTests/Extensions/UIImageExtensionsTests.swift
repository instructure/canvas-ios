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

import XCTest
@testable import Core

class UIImageExtensionsTests: XCTestCase {
    let path = URL(fileURLWithPath: "\(NSTemporaryDirectory())submissions/")
    let image = UIImage(named: "TestImage.png", in: Bundle(for: UIImageExtensionsTests.self), compatibleWith: nil)!

    override func setUp() {
        deleteTempDir()
    }

    func deleteTempDir() {
        do {
            try FileManager.default.removeItem(at: path)
        } catch {
        }
    }

    func testTemporarilyStoreForSubmission() {
        //  when
        let fileInfo = try! image.temporarilyStoreForSubmission()
        let files = try? FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        let data = try? Data(contentsOf: files!.first!)

        //  then
        XCTAssertEqual(files?.first, fileInfo?.url)
        XCTAssertEqual(image.pngData(), data)
    }

    func testIconNamed() {
        for name in UIImage.IconName.allCases {
            XCTAssertEqual(UIImage.icon(name), UIImage(named: "\(name)", in: .core, compatibleWith: nil))
        }
    }
}
