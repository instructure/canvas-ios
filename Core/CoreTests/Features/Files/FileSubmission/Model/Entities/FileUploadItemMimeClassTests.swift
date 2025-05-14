//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest

class FileUploadItemMimeClassTestss: CoreTestCase {

    func testMimeClassJpgClassifiesAsImage() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.jpg")!
        XCTAssertEqual(testee.mimeClass, .image)
    }

    func testMimeClassJpegClassifiesAsImage() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.jpeg")!
        XCTAssertEqual(testee.mimeClass, .image)
    }

    func testMimeClassPngClassifiesAsImage() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.png")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .image)
    }

    func testMimeClassHeicClassifiesAsImage() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.heic")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .image)
    }

    func testMimeClassMp3ClassifiesAsAudio() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.mp3")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .audio)
    }

    func testMimeClassWavClassifiesAsAudio() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.wav")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .audio)
    }

    func testMimeClassMp4ClassifiesAsVideo() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.mp4")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .video)
    }

    func testMimeClassMpegClassifiesAsVideo() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.mpeg")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .video)
    }

    func testMimeClassPdfClassifiesAsPdf() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.pdf")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .pdf)
    }

    func testMimeClassDocClassifiesAsDoc() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.doc")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .doc)
    }

    func testMimeClassDocxClassifiesAsDoc() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.docx")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .doc)
    }

    func testMimeClassRtfClassifiesAsDoc() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/fileName.rtf")!
        print(testee.mimeClass)
        XCTAssertEqual(testee.mimeClass, .doc)
    }
}
