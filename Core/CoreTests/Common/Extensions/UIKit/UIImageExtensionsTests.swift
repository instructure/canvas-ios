//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

    func testWriteDefaults() {
        let now = Date.isoDateFromString("2018-11-15T17:44:54Z")!
        Clock.mockNow(now)
        XCTAssertNoThrow(try image.write())
        let file = URL.Directories.temporary.appendingPathComponent("images/1542303894.0.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))

        Clock.reset()
    }

    func testWriteToURL() {
        let url = URL.Directories.temporary.appendingPathComponent("my-images", isDirectory: true)
        try! image.write(to: url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testWriteWithName() {
        try! image.write(nameIt: "poop")
        let file = URL.Directories.temporary.appendingPathComponent("images/poop.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: file.path))
    }

    func testWriteToURLWithName() {
        let url = URL.Directories.temporary.appendingPathComponent("my-images/poop.jpg")
        try! image.write(to: url, nameIt: "poop")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func testWriteOverwritesExistingFile() {
        let tmp = URL.Directories.temporary
        let file = tmp.appendingPathComponent("hey.jpg")
        try! "hey".write(to: file, atomically: true, encoding: .utf8)
        try! image.write(to: tmp, nameIt: "hey")
        XCTAssertNotNil(UIImage(contentsOfFile: file.path))
        XCTAssertThrowsError(try String(contentsOf: file))
    }
}
