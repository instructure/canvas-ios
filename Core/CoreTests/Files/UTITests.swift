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

import Foundation
@testable import Core
import UniformTypeIdentifiers
import XCTest

class UTITests: XCTestCase {
    func testInitInvalid() {
        XCTAssertNil(UTI(extension: ""))
        XCTAssertNil(UTI(mime: ""))
    }

    func testInitValid() {
        XCTAssertNotNil(UTI(extension: "png"))
        XCTAssertNotNil(UTI(extension: "jpg"))
        XCTAssertNotNil(UTI(extension: "psd"))
        XCTAssertNotNil(UTI(mime: "image/jpeg"))
    }

    func testAny() {
        XCTAssertEqual(UTI.any.rawValue, "public.item")
        XCTAssertTrue(UTI.any.isAny)
    }

    func testVideo() {
        XCTAssertEqual(UTI.video.rawValue, "public.movie")
        XCTAssertTrue(UTI.video.isVideo)
        XCTAssertTrue(UTI(extension: "mp4")!.isVideo)
    }

    func testAudio() {
        XCTAssertEqual(UTI.audio.rawValue, "public.audio")
        XCTAssertTrue(UTI.audio.isAudio)
        XCTAssertTrue(UTI(extension: "mp3")!.isAudio)
    }

    func testImage() {
        XCTAssertEqual(UTI.image.rawValue, "public.image")
        XCTAssertTrue(UTI.image.isImage)
        XCTAssertTrue(UTI(extension: "jpg")!.isImage)
    }

    func testText() {
        XCTAssertEqual(UTI.text.rawValue, "public.text")
    }

    func testURL() {
        XCTAssertEqual(UTI.url.rawValue, "public.url")
    }

    func testFileURL() {
        XCTAssertEqual(UTI.fileURL.rawValue, "public.file-url")
    }

    func testFolder() {
        XCTAssertEqual(UTI.folder.rawValue, "public.folder")
    }

    func testIWork() {
        let result = UTI.from(extensions: ["pages", "key", "numbers"])
        XCTAssert(result.contains(.pagesBundle))
        XCTAssert(result.contains(.pagesSingleFile))
        XCTAssert(result.contains(.keynoteBundle))
        XCTAssert(result.contains(.keynoteSingleFile))
        XCTAssert(result.contains(.numbersBundle))
        XCTAssert(result.contains(.numbersSingleFile))
    }

    func testUTTypeConversion() {
        XCTAssertEqual(UTI.any.uttype, UTType.item)
        XCTAssertEqual(UTI.video.uttype, UTType.movie)
        XCTAssertEqual(UTI.audio.uttype, UTType.audio)
        XCTAssertEqual(UTI.image.uttype, UTType.image)
        XCTAssertEqual(UTI.text.uttype, UTType.text)
        XCTAssertEqual(UTI.url.uttype, UTType.url)
        XCTAssertEqual(UTI.fileURL.uttype, UTType.fileURL)
        XCTAssertEqual(UTI.folder.uttype, UTType.folder)

        XCTAssertEqual(UTI.pagesBundle.uttype?.identifier, UTI.pagesBundleIdentifier)
        XCTAssertEqual(UTI.pagesSingleFile.uttype?.identifier, UTI.pagesSingleFileIdentifier)
        XCTAssertEqual(UTI.keynoteBundle.uttype?.identifier, UTI.keynoteBundleIdentifier)
        XCTAssertEqual(UTI.keynoteSingleFile.uttype?.identifier, UTI.keynoteSingleFileIdentifier)
        XCTAssertEqual(UTI.numbersBundle.uttype?.identifier, UTI.numbersBundleIdentifier)
        XCTAssertEqual(UTI.numbersSingleFile.uttype?.identifier, UTI.numbersSingleFileIdentifier)
    }
}
