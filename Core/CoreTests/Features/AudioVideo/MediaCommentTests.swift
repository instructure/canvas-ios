//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

import XCTest
@testable import Core

class MediaCommentTests: CoreTestCase {
    func testProperties() {
        let mediaComment = MediaComment.make()

        mediaComment.displayName = nil
        XCTAssertNil(mediaComment.displayName)
        mediaComment.displayName = "Display"
        XCTAssertEqual(mediaComment.displayName, "Display")
    }

    func testSave() {
        let apiMediaComment = APIMediaComment.make()

        MediaComment.save(apiMediaComment, in: databaseClient)
        XCTAssertNoThrow(try databaseClient.save())

        let mediaComment: MediaComment = databaseClient.fetch().first!
        XCTAssertEqual(mediaComment.url, apiMediaComment.url)
        XCTAssertEqual(mediaComment.contentType, apiMediaComment.content_type)
        XCTAssertEqual(mediaComment.displayName, apiMediaComment.display_name)
        XCTAssertEqual(mediaComment.mediaID, apiMediaComment.media_id)
        XCTAssertEqual(mediaComment.mediaType.rawValue, apiMediaComment.media_type)
    }
}
