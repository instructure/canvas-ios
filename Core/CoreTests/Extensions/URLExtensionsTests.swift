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

class URLExtensionsTests: XCTestCase {

    let path = URL(fileURLWithPath: "\(NSTemporaryDirectory())submissions/")
    let fs = FileManager.default

    func setup() {
        deleteTempDir()
    }

    func deleteTempDir() {
        XCTAssertNoThrow( try fs.removeItem(at: path) )
    }

    func testLookupFileSize() {
        let url = Bundle(for: URLExtensionsTests.self).url(forResource: "Info", withExtension: "plist")
        XCTAssertGreaterThan(url!.lookupFileSize(), 500)
        XCTAssertEqual(URL(string: "bogus")?.lookupFileSize(), 0)
        XCTAssertEqual(URL(fileURLWithPath: "bogus").lookupFileSize(), 0)
    }

    func testAppendingQueryItems() {
        let url = URL(string: "/api/v1/foo")?.appendingQueryItems(URLQueryItem(name: "a", value: "b"), URLQueryItem(name: "c", value: nil))
        XCTAssertEqual(url?.absoluteString, "/api/v1/foo?a=b&c")
    }

    func testTemporaryDirectory() {
        XCTAssertEqual(URL.Directories.temporary, URL(fileURLWithPath: NSTemporaryDirectory()))
    }

    func testCachesDirectory() {
        XCTAssertEqual(URL.Directories.caches, fs.urls(for: .cachesDirectory, in: .userDomainMask)[0])
        XCTAssertEqual(URL.Directories.caches, URL.Directories.caches(appGroup: nil))
    }

    func testAppGroupCachesDirectory() {
        let expected = URL.Directories.sharedContainers("group.instructure.shared")!.appendingPathComponent("caches", isDirectory: true)
        let url = URL.Directories.caches(appGroup: "group.instructure.shared")
        XCTAssertEqual(url, expected)
        var isDir: ObjCBool = false
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir))
        XCTAssertTrue(isDir.boolValue)
    }

    func testDocumentsDirectory() {
        XCTAssertEqual(URL.Directories.documents, fs.urls(for: .documentDirectory, in: .userDomainMask)[0])
    }

    func testMove() throws {
        let url = URL.Directories.temporary.appendingPathComponent("original.txt")
        try "data".write(to: url, atomically: true, encoding: .utf8)
        let destination = URL.Directories.temporary.appendingPathComponent("somewhere/over/the/rainbow/other.txt")
        try? fs.removeItem(at: destination)
        try url.move(to: destination)
        XCTAssertTrue(fs.fileExists(atPath: destination.path))
        XCTAssertFalse(fs.fileExists(atPath: url.path))
        try? fs.removeItem(at: url)
        try fs.removeItem(at: destination)
    }

    func testMoveOverride() throws {
        let existing = URL.Directories.temporary.appendingPathComponent("file.txt")
        try "existing".write(to: existing, atomically: true, encoding: .utf8)
        let new = URL.Directories.caches.appendingPathComponent("file.txt") // same name will cause error w/o override: true
        try "new".write(to: new, atomically: true, encoding: .utf8)
        XCTAssertThrowsError(try new.move(to: existing, override: false))
        XCTAssertNoThrow(try new.move(to: existing, override: true))
        XCTAssertFalse(fs.fileExists(atPath: new.path))
        XCTAssertTrue(fs.fileExists(atPath: existing.path))
        let result = try String(contentsOf: existing)
        XCTAssertEqual(result, "new")
        try? fs.removeItem(at: new)
        try fs.removeItem(at: existing)
    }

    func testMoveCopy() throws {
        let source = URL.Directories.temporary.appendingPathComponent("source.txt")
        try? fs.removeItem(at: source)
        try "source".write(to: source, atomically: true, encoding: .utf8)
        let destination = URL.Directories.temporary.appendingPathComponent("destination.txt")
        try source.move(to: destination, copy: true)
        XCTAssertTrue(fs.fileExists(atPath: source.path))
        XCTAssertTrue(fs.fileExists(atPath: destination.path))
        let text = try String(contentsOf: destination)
        XCTAssertEqual(text, "source")
        try fs.removeItem(at: source)
        try fs.removeItem(at: destination)
    }

    func testCopy() throws {
        let source = URL.Directories.temporary.appendingPathComponent("source.txt")
        try? fs.removeItem(at: source)
        try "source".write(to: source, atomically: true, encoding: .utf8)
        let destination = URL.Directories.temporary.appendingPathComponent("destination.txt")
        try source.copy(to: destination)
        XCTAssertTrue(fs.fileExists(atPath: source.path))
        XCTAssertTrue(fs.fileExists(atPath: destination.path))
        let text = try String(contentsOf: destination)
        XCTAssertEqual(text, "source")
        try fs.removeItem(at: source)
        try fs.removeItem(at: destination)
    }

    func testContainsQueryItem() {
        var testee = URL(string: "/path/to/resource")!
        XCTAssertFalse(testee.containsQueryItem(named: "embed"))

        testee = URL(string: "/path/to/resource?embed=true")!
        XCTAssertTrue(testee.containsQueryItem(named: "embed"))

        testee = URL(string: "/path/to/resource?param=value&embed=true")!
        XCTAssertTrue(testee.containsQueryItem(named: "embed"))
    }

    func testPathExtensions() {
        let urls = [
            URL(string: "/file")!,
            URL(string: "/file.txt")!,
            URL(string: "https://instructure.com/file.png")!,
            URL(string: "/file.jpeg")!,
        ]
        XCTAssertEqual(urls.pathExtensions, Set(["txt", "jpeg", "png"]))
    }
}
