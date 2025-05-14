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

    func testDownloadsVideoAndInvokesPosterGeneration() {
        let mockCacheInteractor = MockStudioVideoCacheInteractor(isVideoDownloadedResult: false)
        let mockCaptionsInteractor = MockStudioCaptionsInteractor()
        let mockPosterInteractor = MockStudioVideoPosterInteractor()
        let testee = StudioVideoDownloadInteractorLive(
            documentsDirectory: workingDirectory,
            captionsInteractor: mockCaptionsInteractor,
            videoCacheInteractor: mockCacheInteractor,
            posterInteractor: mockPosterInteractor
        )

        let expectedVideoURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/\(TestData.mediaID.value).mp4")
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedVideoURL.path()), false)
        let expectedPosterURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/poster.png")
        mockPosterInteractor.posterLocationResult = expectedPosterURL
        let expectedCaptionURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/\(TestData.caption.srclang).vtt")
        mockCaptionsInteractor.mockedCaptionURL = expectedCaptionURL

        let expectedResult = try! StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: expectedVideoURL,
            videoPosterLocation: expectedPosterURL,
            videoMimeType: TestData.mimeType,
            captionLocations: [expectedCaptionURL],
            baseURL: workingDirectory
        )

        // WHEN
        XCTAssertSingleOutputEquals(
            testee.download(TestData.downloadable, rootDirectory: workingDirectory),
            expectedResult,
            timeout: 1
        )

        // THEN
        XCTAssertEqual(mockCaptionsInteractor.receivedCaptionsToWrite, [TestData.caption])
        XCTAssertEqual(FileManager.default.fileExists(atPath: expectedVideoURL.path()), true)
        XCTAssertEqual(mockPosterInteractor.receivedCachedFlag, false)
        XCTAssertEqual(mockPosterInteractor.receivedVideoFile, expectedVideoURL)
        XCTAssertEqual(mockPosterInteractor.receivedMediaFolder, workingDirectory.appending(path: "\(TestData.mediaID.value)/"))
    }

    func testSkipsDownloadWhenVideoIsAlreadyCached() {
        let mockCacheInteractor = MockStudioVideoCacheInteractor(isVideoDownloadedResult: true)
        let mockCaptionsInteractor = MockStudioCaptionsInteractor()
        let testee = StudioVideoDownloadInteractorLive(
            documentsDirectory: workingDirectory,
            captionsInteractor: mockCaptionsInteractor,
            videoCacheInteractor: mockCacheInteractor,
            posterInteractor: MockStudioVideoPosterInteractor()
        )
        let expectedVideoURL = workingDirectory.appending(path: "\(TestData.mediaID.value)/\(TestData.mediaID.value).mp4")

        // WHEN
        XCTAssertFinish(testee.download(TestData.downloadable, rootDirectory: workingDirectory), timeout: 1)

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

class MockStudioVideoPosterInteractor: StudioVideoPosterInteractor {
    public var posterLocationResult: URL?

    private(set) var receivedCachedFlag: Bool?
    private(set) var receivedMediaFolder: URL?
    private(set) var receivedVideoFile: URL?

    func createVideoPosterIfNeeded(
        isVideoCached: Bool,
        mediaFolder: URL,
        videoFile: URL
    ) -> URL? {
        receivedCachedFlag = isVideoCached
        receivedMediaFolder = mediaFolder
        receivedVideoFile = videoFile
        return posterLocationResult
    }
}
