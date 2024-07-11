//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

@testable import Core
import XCTest

class StudioCaptionsInteractorTests: CoreTestCase {
    private let srtContentEn = """
    1
    00:00:01,000 --> 00:00:02,000
    Test caption line 1.

    2
    00:00:03,000 --> 00:00:04,000
    Test caption line 2.
    """
    private let vttContentEn = """
    WEBVTT

    1
    00:00:01.000 --> 00:00:02.000
    Test caption line 1.

    2
    00:00:03.000 --> 00:00:04.000
    Test caption line 2.
    """
    private let srtContentHu = """
    1
    00:00:01,000 --> 00:00:02,000
    Teszt felirat sor 1.

    2
    00:00:03,000 --> 00:00:04,000
    Teszt felirat sor 2.
    """
    private let vttContentHu = """
    WEBVTT

    1
    00:00:01.000 --> 00:00:02.000
    Teszt felirat sor 1.

    2
    00:00:03.000 --> 00:00:04.000
    Teszt felirat sor 2.
    """

    func testWritesCaptionsInVttFormat() throws {
        let captionEn = APIStudioMediaItem.Caption(
            srclang: "en",
            label: "",
            data: srtContentEn
        )
        let captionHu = APIStudioMediaItem.Caption(
            srclang: "hu",
            label: "",
            data: srtContentHu
        )

        // WHEN
        XCTAssertFinish(StudioCaptionsInteractor().write(
            captions: [captionEn, captionHu],
            to: workingDirectory
        ))

        // THEN
        let captionEnFile = workingDirectory.appendingPathComponent("en.vtt", isDirectory: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: captionEnFile.path()))
        let captionEnFileData = try Data(contentsOf: captionEnFile)
        XCTAssertEqual(
            String(data: captionEnFileData, encoding: .utf8),
            vttContentEn
        )

        let captionHuFile = workingDirectory.appendingPathComponent("hu.vtt", isDirectory: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: captionHuFile.path()))
        let captionHuFileData = try Data(contentsOf: captionHuFile)
        XCTAssertEqual(
            String(data: captionHuFileData, encoding: .utf8),
            vttContentHu
        )
    }
}
