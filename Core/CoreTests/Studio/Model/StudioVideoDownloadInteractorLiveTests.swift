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
import Combine
import XCTest

class StudioVideoDownloadInteractorLiveTests: CoreTestCase {
    private enum TestData {
        static let caption = APIStudioMediaItem.Caption(
            srclang: "en",
            label: "English",
            data: "1\n00:00:02.000 --> 00:00:04.000\nShowing blanket with skiing bears on it."
        )
        static let mediaID = ID("123")
        static let mimeType = "video/mp4"
        static let downloadable = APIStudioMediaItem(
            id: mediaID,
            lti_launch_id: StudioTestData.ltiLaunchID,
            title: "Test Video",
            mime_type: mimeType,
            size: 576,
            url: Bundle(for: StudioVideoDownloadInteractorLiveTests.self).url(
                forResource: "preview_test",
                withExtension: "mp4"
            )!,
            captions: [caption]
        )
    }

    override func setUp() {
        super.setUp()
        API.resetMocks(useMocks: false)
    }

    func testDownloadsVideoAndGeneratesPoster() {
        let mockCacheInteractor = MockStudioVideoCacheInteractor(isVideoDownloadedResult: false)
        let mockCaptionsInteractor = MockStudioCaptionsInteractor()
        let testee = StudioVideoDownloadInteractorLive(
            rootDirectory: workingDirectory,
            captionsInteractor: mockCaptionsInteractor,
            videoCacheInteractor: mockCacheInteractor
        )

        let expectedVideoURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/\(TestData.mediaID.value).mp4")
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedVideoURL.path()), false)
        let expectedPosterURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/poster.png")
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), false)
        let expectedCaptionURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/\(TestData.caption.srclang).vtt")
        mockCaptionsInteractor.mockedCaptionURL = expectedCaptionURL

        let expectedResult = StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: expectedVideoURL,
            videoPosterLocation: expectedPosterURL,
            videoMimeType: TestData.mimeType,
            captionLocations: [expectedCaptionURL]
        )

        // WHEN
        XCTAssertSingleOutputEquals(testee.download(TestData.downloadable), expectedResult, timeout: 1)

        // THEN
        XCTAssertEqual(mockCaptionsInteractor.receivedCaptionsToWrite, [TestData.caption])
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedVideoURL.path()), true)
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedPosterURL.path()), true)
    }

    func testSkipsDownloadWhenVideoIsAlreadyCached() {
        let mockCacheInteractor = MockStudioVideoCacheInteractor(isVideoDownloadedResult: true)
        let mockCaptionsInteractor = MockStudioCaptionsInteractor()
        let testee = StudioVideoDownloadInteractorLive(
            rootDirectory: workingDirectory,
            captionsInteractor: mockCaptionsInteractor,
            videoCacheInteractor: mockCacheInteractor
        )
        let expectedVideoURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/\(TestData.mediaID.value).mp4")

        // WHEN
        XCTAssertFinish(testee.download(TestData.downloadable), timeout: 1)

        // THEN
        XCTAssertEqual(mockCacheInteractor.receivedExpectedSize, TestData.downloadable.size)
        XCTAssertEqual(mockCacheInteractor.receivedVideoLocation, expectedVideoURL)
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedVideoURL.path()), false)
    }
}

class MockStudioCaptionsInteractor: StudioCaptionsInteractor {
    private(set) var receivedCaptionsToWrite: [APIStudioMediaItem.Caption] = []
    public var mockedCaptionURL: URL?

    public func write(
        captions: [APIStudioMediaItem.Caption],
        to directory: URL
    ) -> AnyPublisher<[URL], Error> {
        receivedCaptionsToWrite = captions
        return Just(mockedCaptionURL != nil ? [mockedCaptionURL!] : [])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class MockStudioVideoCacheInteractor: StudioVideoCacheInteractor {
    public let isVideoDownloadedResult: Bool

    private(set) var receivedVideoLocation: URL?
    private(set) var receivedExpectedSize: Int?

    init(isVideoDownloadedResult: Bool) {
        self.isVideoDownloadedResult = isVideoDownloadedResult
    }

    public func isVideoDownloaded(
        videoLocation: URL,
        expectedSize: Int
    ) -> Bool {
        receivedVideoLocation = videoLocation
        receivedExpectedSize = expectedSize
        return isVideoDownloadedResult
    }
}
