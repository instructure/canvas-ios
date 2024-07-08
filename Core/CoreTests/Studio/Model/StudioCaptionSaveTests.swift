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

class StudioCaptionSaveTests: AbstractStudioTest {

    @available(iOS 16.0, *)
    func testSavesCaptions() throws {
        let caption1Content = "english caption"
        let caption1 = APIStudioMediaItem.Caption(
            srclang: "en",
            label: "",
            data: caption1Content
        )
        let caption2Content = "magyar felirat"
        let caption2 = APIStudioMediaItem.Caption(
            srclang: "hu",
            label: "",
            data: caption2Content
        )

        // WHEN
        XCTAssertFinish([caption1, caption2].write(
            to: workingDirectory
        ))

        // THEN
        let caption1File = workingDirectory.appendingPathComponent("en.vtt", isDirectory: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: caption1File.path()))
        let caption1FileData = try Data(contentsOf: caption1File)
        XCTAssertEqual(String(data: caption1FileData, encoding: .utf8), caption1Content)

        let caption2File = workingDirectory.appendingPathComponent("hu.vtt", isDirectory: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: caption2File.path()))
        let caption2FileData = try Data(contentsOf: caption2File)
        XCTAssertEqual(String(data: caption2FileData, encoding: .utf8), caption2Content)
    }
}
