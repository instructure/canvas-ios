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

    func testIconNamed() {
        for name in UIImage.IconName.allCases {
            XCTAssertEqual(UIImage.icon(name), UIImage(named: "\(name)", in: .core, compatibleWith: nil))
        }
    }

    func testWriteDefaults() {
        let now = Date.isoDateFromString("2018-11-15T17:44:54Z")!
        Clock.mockNow(now)
        XCTAssertNoThrow(try image.write())
        let file = URL.temporaryDirectory.appendingPathComponent("images/1542303894.0.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
    }

    func testWriteToURL() {
        let url = URL.temporaryDirectory.appendingPathComponent("my-images", isDirectory: true)
        try! image.write(to: url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testWriteWithName() {
        try! image.write(nameIt: "poop")
        let file = URL.temporaryDirectory.appendingPathComponent("images/poop.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
    }

    func testWriteToURLWithName() {
        let url = URL.temporaryDirectory.appendingPathComponent("my-images/poop.jpg")
        try! image.write(to: url, nameIt: "poop")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testWriteOverwritesExistingFile() {
        let tmp = URL.temporaryDirectory
        let file = tmp.appendingPathComponent("hey.jpg")
        try! "hey".write(to: file, atomically: true, encoding: .utf8)
        try! image.write(to: tmp, nameIt: "hey")
        XCTAssertNotNil(UIImage(contentsOfFile: file.path))
        XCTAssertThrowsError(try String(contentsOf: file))
    }
}
