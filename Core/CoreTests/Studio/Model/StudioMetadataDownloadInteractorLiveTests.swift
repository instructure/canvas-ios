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

class StudioMetadataDownloadInteractorLiveTests: CoreTestCase {
    enum TestData {
        static let mediaItem1 = APIStudioMediaItem(
            id: ID(1),
            lti_launch_id: "1",
            title: "1",
            mime_type: "1",
            size: 1,
            url: .make(),
            captions: []
        )
        static let mediaItem2 = APIStudioMediaItem(
            id: ID(2),
            lti_launch_id: "2",
            title: "2",
            mime_type: "2",
            size: 2,
            url: .make(),
            captions: []
        )
    }

    func testDownloadsMediaItems() {
        let testee: StudioMetadataDownloadInteractor = StudioMetadataDownloadInteractorLive()

        api.mock(
            GetStudioCourseMediaRequest(courseId: "1"),
            value: [TestData.mediaItem1]
        )
        api.mock(
            GetStudioCourseMediaRequest(courseId: "2"),
            value: [TestData.mediaItem2]
        )

        // WHEN
        let publisher = testee.fetchStudioMediaItems(api: api, courseIDs: ["1", "2"])

        // THEN
        XCTAssertSingleOutputEquals(
            publisher,
            [TestData.mediaItem1, TestData.mediaItem2]
        )
    }

    func testDownloadSucceedsInCaseACourseHasNoStudioVideo() {
        let testee: StudioMetadataDownloadInteractor = StudioMetadataDownloadInteractorLive()

        api.mock(
            GetStudioCourseMediaRequest(courseId: "1"),
            value: [TestData.mediaItem1]
        )
        // If a course has no embedded studio videos the API will return 404
        api.mock(GetStudioCourseMediaRequest(courseId: "2")) { _ in
            (nil, nil, NSError.instructureError("", code: HttpError.notFound))
        }

        // WHEN
        let publisher = testee.fetchStudioMediaItems(api: api, courseIDs: ["1", "2"])

        // THEN
        XCTAssertSingleOutputEquals(
            publisher,
            [TestData.mediaItem1]
        )
    }

    func testFailsOnErrorsOtherThanNotFoundError() {
        let testee: StudioMetadataDownloadInteractor = StudioMetadataDownloadInteractorLive()

        api.mock(
            GetStudioCourseMediaRequest(courseId: "1"),
            value: [TestData.mediaItem1]
        )
        api.mock(GetStudioCourseMediaRequest(courseId: "2")) { _ in
            (nil, nil, NSError.instructureError("", code: HttpError.forbidden))
        }

        // WHEN
        let publisher = testee.fetchStudioMediaItems(api: api, courseIDs: ["1", "2"])

        // THEN
        XCTAssertFailure(publisher)
    }
}
