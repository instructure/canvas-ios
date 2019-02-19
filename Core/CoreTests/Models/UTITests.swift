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
import Core
import XCTest

class UTITests: XCTestCase {
    func testInitInvalid() {
        let empty = UTI(extension: "")
        XCTAssertNil(empty)
    }

    func testInitValid() {
        let png = UTI(extension: "png")
        XCTAssertNotNil(png)

        let jpg = UTI(extension: "jpg")
        XCTAssertNotNil(jpg)

        let psd = UTI(extension: "psd")
        XCTAssertNotNil(psd)
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
}
