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

class StudioIFrameDiscoveryInteractorLiveTests: CoreTestCase {

    func testDiscoversIFrame() throws {
        var validCourseHtmlURL = workingDirectory.appendingPathComponent("validcourse-1")
        try FileManager.default.createDirectory(at: validCourseHtmlURL, withIntermediateDirectories: true)
        validCourseHtmlURL.append(path: "test.html", directoryHint: .notDirectory)
        try StudioTestData.html.write(to: validCourseHtmlURL, atomically: false, encoding: .utf8)

        var invalidCourseHtmlURL = workingDirectory.appendingPathComponent("invalidcourse-2")
        try FileManager.default.createDirectory(at: invalidCourseHtmlURL, withIntermediateDirectories: true)
        invalidCourseHtmlURL.append(path: "test.html", directoryHint: .notDirectory)
        try StudioTestData.html.write(to: invalidCourseHtmlURL, atomically: false, encoding: .utf8)

        let testee = StudioIFrameDiscoveryInteractorLive(studioHtmlParser: StudioHTMLParserInteractorLive())

        // WHEN
        let publisher = testee.discoverStudioIFrames(
            in: workingDirectory,
            courseIDs: ["1"]
        )

        // THEN
        let expectedResult = [validCourseHtmlURL: [StudioIFrame(
            mediaLTILaunchID: StudioTestData.ltiLaunchID,
            sourceHtml: StudioTestData.iframe
        )]]
        XCTAssertSingleOutputEquals(
            publisher,
            expectedResult
        )
    }
}
