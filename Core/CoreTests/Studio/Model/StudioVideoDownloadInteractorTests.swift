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

class StudioVideoDownloadInteractorTests: CoreTestCase {

    func testDownloadsVideoAndGeneratesPoster() {
        let caption = APIStudioMediaItem.Caption(
            srclang: "en",
            label: "English",
            data: "1\n00:00:02.000 --> 00:00:04.000\nShowing blanket with skiing bears on it."
        )
        let mediaID = ID("123")
        let mimeType = "video/mp4"
        let downloadable = APIStudioMediaItem(
            id: mediaID,
            lti_launch_id: StudioTestData.ltiLaunchID,
            title: "Test Video",
            mime_type: mimeType,
            size: 576,
            url: Bundle(for: Self.self).url(
                forResource: "preview_test",
                withExtension: "mp4"
            )!,
            captions: [caption]
        )
        let captionsMock = MockStudioCaptionsInteractor()
        let testee = StudioVideoDownloadInteractor(
            rootDirectory: workingDirectory,
            captionsInteractor: captionsMock
        )
        let publisher = testee.download(downloadable)
        let expectedVideoURL = workingDirectory.appending(path: "\(mediaID.value)/\(mediaID.value).mp4")
        let expectedPosterURL = workingDirectory.appending(path: "\(mediaID.value)/poster.png")
        let expectedCaptionURL = workingDirectory.appending(path: "\(mediaID.value)/\(caption.srclang).vtt")
        captionsMock.mockedCaptionURL = expectedCaptionURL

        let expectedResult = StudioOfflineVideo(
            ltiLaunchID: StudioTestData.ltiLaunchID,
            videoLocation: expectedVideoURL,
            videoPosterLocation: expectedPosterURL,
            videoMimeType: mimeType,
            captionLocations: [expectedCaptionURL]
        )

        // WHEN
        XCTAssertSingleOutputEquals(publisher, expectedResult, timeout: 1)

        // THEN
        XCTAssertEqual(captionsMock.didWriteCaptions, [caption])
    }
}

class MockStudioCaptionsInteractor: StudioCaptionsInteractor {
    private(set) var didWriteCaptions: [APIStudioMediaItem.Caption] = []
    public var mockedCaptionURL: URL?

    override public func write(
        captions: [APIStudioMediaItem.Caption],
        to directory: URL
    ) -> AnyPublisher<[URL], Error> {
        didWriteCaptions = captions
        return Just(mockedCaptionURL != nil ? [mockedCaptionURL!] : [])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
