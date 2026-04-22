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
        var subscriptions = Set<AnyCancellable>()
        let finishedPosterCreationExpectation = expectation(description: "finishedPosterCreationExpectation")
        var posterURL: URL?

        let testee = StudioVideoPosterInteractorLive()
        let expectedPosterURL = workingDirectory.appending(path: "123/poster.png")

        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), false)

        // WHEN
        testee.createVideoPosterIfNeeded(
            isVideoCached: false,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )
        .sink { url in
            posterURL = url
            finishedPosterCreationExpectation.fulfill()
        }
        .store(in: &subscriptions)

        wait(for: [finishedPosterCreationExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), true)
        XCTAssertEqual(posterURL, expectedPosterURL)
    }

    func testSkipsPosterGenerationIfVideoIsCached() {
        var subscriptions = Set<AnyCancellable>()
        let finishedPosterCreationExpectation = expectation(description: "finishedPosterCreationExpectation")
        var posterURL: URL?

        let posterFactoryNotCalled = expectation(description: "posterFactoryNotCalled")
        posterFactoryNotCalled.isInverted = true
        let testee = StudioVideoPosterInteractorLive { _, _ in
            posterFactoryNotCalled.fulfill()
        }
        let expectedPosterURL = workingDirectory.appending(path: "123/poster.png")
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), false)

        // WHEN
        testee.createVideoPosterIfNeeded(
            isVideoCached: true,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )
        .sink { url in
            posterURL = url
            finishedPosterCreationExpectation.fulfill()
        }
        .store(in: &subscriptions)

        wait(for: [finishedPosterCreationExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), false)
        XCTAssertEqual(posterURL, expectedPosterURL)
        wait(for: [posterFactoryNotCalled], timeout: 1)
    }

    func testSwallowsNoVideoTrackError() {
        var subscriptions = Set<AnyCancellable>()
        let finishedPosterCreationExpectation = expectation(description: "finishedPosterCreationExpectation")
        var posterURL: URL?

        let testee = StudioVideoPosterInteractorLive { _, _ in
            throw NSError(domain: AVFoundationErrorDomain, code: AVError.Code.noSourceTrack.rawValue)
        }

        // WHEN
        testee.createVideoPosterIfNeeded(
            isVideoCached: false,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )
        .sink { url in
            posterURL = url
            finishedPosterCreationExpectation.fulfill()
        }
        .store(in: &subscriptions)

        wait(for: [finishedPosterCreationExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(posterURL, nil)
        XCTAssertEqual(remoteLogHandler.totalErrorCount, 0)
    }

    func testReportsUnknownErrors() {
        var subscriptions = Set<AnyCancellable>()
        let finishedPosterCreationExpectation = expectation(description: "finishedPosterCreationExpectation")
        var posterURL: URL?

        let testee = StudioVideoPosterInteractorLive { _, _ in
            throw NSError.instructureError("random error")
        }

        // WHEN
        testee.createVideoPosterIfNeeded(
            isVideoCached: false,
            mediaFolder: mediaFolder,
            videoFile: videoURL
        )
        .sink { url in
            posterURL = url
            finishedPosterCreationExpectation.fulfill()
        }
        .store(in: &subscriptions)

        wait(for: [finishedPosterCreationExpectation], timeout: 1)

        // THEN
        XCTAssertEqual(posterURL, nil)
        XCTAssertEqual(remoteLogHandler.totalErrorCount, 1)
        XCTAssertEqual(remoteLogHandler.lastErrorName, "Studio Offline Sync Failed")
        XCTAssertEqual(remoteLogHandler.lastErrorReason, "random error")
    }
}
