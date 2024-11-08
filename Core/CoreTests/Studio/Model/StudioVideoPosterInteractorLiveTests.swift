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

import AVFoundation
@testable import Core
import Combine
import XCTest

class StudioVideoPosterInteractorLiveTests: CoreTestCase {
    lazy var mediaFolder = workingDirectory.appending(path: "123/")
    let videoURL = Bundle(for: StudioVideoPosterInteractorLiveTests.self).url(
        forResource: "preview_test",
        withExtension: "mp4"
    )!

    func testGeneratesPoster() {
        let testee = StudioVideoPosterInteractorLive()
        let expectedPosterURL = workingDirectory.appending(path: "123/poster.png")
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), false)

        // WHEN
        let posterURL = testee.createVideoPosterIfNeeded(
            isVideoCached: false,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )

        // THEN
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), true)
        XCTAssertEqual(posterURL, expectedPosterURL)
    }

    func testSkipsPosterGenerationIfVideoIsCached() {
        let posterFactoryNotCalled = expectation(description: "posterFactoryNotCalled")
        posterFactoryNotCalled.isInverted = true
        let testee = StudioVideoPosterInteractorLive { _, _ in
            posterFactoryNotCalled.fulfill()
        }
        let expectedPosterURL = workingDirectory.appending(path: "123/poster.png")
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), false)

        // WHEN
        let posterURL = testee.createVideoPosterIfNeeded(
            isVideoCached: true,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )

        // THEN
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), false)
        XCTAssertEqual(posterURL, expectedPosterURL)
        wait(for: [posterFactoryNotCalled], timeout: 0.1)
    }

    func testSwallowsNoVideoTrackError() {
        let testee = StudioVideoPosterInteractorLive { _, _ in
            throw NSError(domain: AVFoundationErrorDomain, code: AVError.Code.noSourceTrack.rawValue)
        }

        // WHEN
        let posterURL = testee.createVideoPosterIfNeeded(
            isVideoCached: false,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )

        // THEN
        XCTAssertEqual(posterURL, nil)
        XCTAssertEqual(developerAnalytics.totalErrorCount, 0)
    }

    func testReportsUnknownErrors() {
        let testee = StudioVideoPosterInteractorLive { _, _ in
            throw NSError.instructureError("random error")
        }

        // WHEN
        let posterURL = testee.createVideoPosterIfNeeded(
            isVideoCached: false,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )

        // THEN
        XCTAssertEqual(posterURL, nil)
        XCTAssertEqual(developerAnalytics.totalErrorCount, 1)
        XCTAssertEqual(developerAnalytics.lastErrorName, "Studio Offline Sync Failed")
        XCTAssertEqual(developerAnalytics.lastErrorReason, "random error")
    }
}
