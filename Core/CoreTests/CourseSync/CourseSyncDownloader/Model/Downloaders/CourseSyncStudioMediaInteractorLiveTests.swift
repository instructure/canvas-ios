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

import Combine
@testable import Core
import XCTest

class CourseSyncStudioMediaInteractorLiveTests: CoreTestCase {

    func testDownload() {
        let mockOfflineDirectory = URL.make()

        // Step 1 - Discover iframes
        let mockIFrameDiscoveryInteracor = MockStudioIFrameDiscoveryInteractor()
        let mockLocalHtmlContentURL = URL(
            string: "course_1/pages/body.html"
        )!
        let mockDiscoveredIFrames = [StudioIFrame(
            mediaLTILaunchID: StudioTestData.ltiLaunchID,
            sourceHtml: StudioTestData.iframe
        )]
        mockIFrameDiscoveryInteracor.mockedDiscoverResult = [
            mockLocalHtmlContentURL: mockDiscoveredIFrames
        ]

        // Step 2 - Authenticate with the Studio API
        let mockAuthInteractor = MockStudioAPIAuthInteractor()

        // Step 3 - Download video metadata
        let mockVideoRemoteURL = URL.make()
        let apiMediaItem = APIStudioMediaItem(
            id: ID("api_media_id"),
            lti_launch_id: StudioTestData.ltiLaunchID,
            title: "",
            mime_type: "",
            size: 0,
            url: mockVideoRemoteURL,
            captions: []
        )
        let mockMedatadaDownloader = MockStudioMetadataDownloadInteractor()
        mockMedatadaDownloader.response = [apiMediaItem]

        // Step 4 - Clean up downloaded videos we don't use anymore
        let mockCleanupInteractor = MockStudioVideoCleanupInteractor()

        // Step 5 - Download actual video files
        let mockDownloadInteractor = MockStudioVideoDownloadInteractor()
        let mockOfflineVideo = StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: .make(),
            videoPosterLocation: .make(),
            videoMimeType: "",
            captionLocations: []
        )
        mockDownloadInteractor.mockedOfflineVideoReponse = mockOfflineVideo

        // Step 6 - Write offline urls back to htmls
        let mockIFrameReplaceInteractor = MockStudioIFrameReplaceInteractor()

        let testee = CourseSyncStudioMediaInteractorLive(
            offlineDirectory: mockOfflineDirectory,
            authInteractor: mockAuthInteractor,
            iFrameReplaceInteractor: mockIFrameReplaceInteractor,
            iFrameDiscoveryInteractor: mockIFrameDiscoveryInteracor,
            cleanupInteractor: mockCleanupInteractor,
            metadataDownloadInteractor: mockMedatadaDownloader,
            downloadInteractor: mockDownloadInteractor,
            scheduler: .immediate
        )

        XCTAssertFinish(testee.getContent(courseIDs: ["1"]))

        // Step 1
        XCTAssertTrue(mockIFrameDiscoveryInteracor.discoverCalled)
        XCTAssertEqual(
            mockIFrameDiscoveryInteracor.receivedOfflineDirectory,
            mockOfflineDirectory
        )
        XCTAssertEqual(
            mockIFrameDiscoveryInteracor.receivedCourseIDs,
            ["1"]
        )

        // Step 2
        XCTAssertTrue(mockAuthInteractor.makeAPICalled)

        // Step 3
        XCTAssertTrue(mockMedatadaDownloader.fetchCalled)

        // Step 4
        XCTAssertEqual(
            mockCleanupInteractor.receivedAPIMediaItems,
            [apiMediaItem]
        )
        XCTAssertEqual(
            mockCleanupInteractor.receivedLTIIDsForOfflineMode,
            [StudioTestData.ltiLaunchID]
        )

        // Step 5
        XCTAssertEqual(
            mockDownloadInteractor.receivedMediaItem,
            apiMediaItem
        )

        // Step 6
        XCTAssertEqual(
            mockIFrameReplaceInteractor.receivedHtmlURL,
            mockLocalHtmlContentURL
        )
        XCTAssertEqual(
            mockIFrameReplaceInteractor.receivedIFrames,
            mockDiscoveredIFrames
        )
        XCTAssertEqual(
            mockIFrameReplaceInteractor.receivedOfflineVideos,
            [mockOfflineVideo]
        )
    }
}

private class MockStudioAPIAuthInteractor: StudioAPIAuthInteractor {
    private(set) var makeAPICalled = false

    public func makeStudioAPI() -> AnyPublisher<API, StudioAPIAuthError> {
        makeAPICalled = true
        return Just(API())
            .setFailureType(to: StudioAPIAuthError.self)
            .eraseToAnyPublisher()
    }
}

private class MockStudioIFrameReplaceInteractor: StudioIFrameReplaceInteractor {
    private(set) var receivedHtmlURL: URL?
    private(set) var receivedIFrames: [StudioIFrame] = []
    private(set) var receivedOfflineVideos: [StudioOfflineVideo] = []

    public func replaceStudioIFrames(
        inHtmlAtURL htmlURL: URL,
        iframes: [StudioIFrame],
        offlineVideos: [StudioOfflineVideo]
    ) throws {
        receivedHtmlURL = htmlURL
        receivedIFrames = iframes
        receivedOfflineVideos = offlineVideos
    }
}

private class MockStudioIFrameDiscoveryInteractor: StudioIFrameDiscoveryInteractor {
    public var mockedDiscoverResult: StudioIFramesByLocation!
    private(set) var discoverCalled = false
    private(set) var receivedOfflineDirectory: URL?
    private(set) var receivedCourseIDs: [String] = []

    init() {}

    public func discoverStudioIFrames(
        in offlineDirectory: URL,
        courseIDs: [String]
    ) -> AnyPublisher<StudioIFramesByLocation, Never> {
        discoverCalled = true
        receivedOfflineDirectory = offlineDirectory
        receivedCourseIDs = courseIDs
        return Just(mockedDiscoverResult).eraseToAnyPublisher()
    }
}

private class MockStudioVideoDownloadInteractor: StudioVideoDownloadInteractor {
    public var mockedOfflineVideoReponse: StudioOfflineVideo!
    private(set) var receivedMediaItem: APIStudioMediaItem?

    init() {}

    public func download(
        _ item: APIStudioMediaItem
    ) -> AnyPublisher<StudioOfflineVideo, Error> {
        receivedMediaItem = item
        return Just(mockedOfflineVideoReponse)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class MockStudioHTMLParserInteractor: StudioHTMLParserInteractor {

    func extractStudioIFrames(htmlLocation: URL) -> [Core.StudioIFrame] {
        []
    }
}

private class MockStudioVideoCleanupInteractor: StudioVideoCleanupInteractor {
    private(set) var receivedAPIMediaItems: [APIStudioMediaItem]?
    private(set) var receivedLTIIDsForOfflineMode: [String]?

    init() {}

    public func removeNoLongerNeededVideos(
        allMediaItemsOnAPI: [APIStudioMediaItem],
        mediaLTIIDsUsedInOfflineMode: [String]
    ) -> AnyPublisher<Void, Error> {
        receivedAPIMediaItems = allMediaItemsOnAPI
        receivedLTIIDsForOfflineMode = mediaLTIIDsUsedInOfflineMode
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private class MockStudioMetadataDownloadInteractor: StudioMetadataDownloadInteractor {
    var response: [APIStudioMediaItem] = []
    private(set) var fetchCalled = false

    func fetchStudioMediaItems(
        api: API,
        courseIDs: [String]
    ) -> AnyPublisher<[APIStudioMediaItem], Error> {
        fetchCalled = true
        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
