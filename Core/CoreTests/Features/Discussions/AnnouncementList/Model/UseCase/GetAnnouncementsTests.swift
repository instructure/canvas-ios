//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
import XCTest
@testable import Core

class GetAnnouncementsTests: CoreTestCase {
    func testPageIndexSaveOnGetAnnouncements() {
        let testee = GetAnnouncements(context: .course("1"))
        let requestedURL = URL(string: "/courses/1/announcements?page=2&per_page=100")!
        let urlResponse = URLResponse(url: requestedURL, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let announcement = DiscussionTopic.make()

        XCTAssertEqual(announcement.position, Int.max)
        testee.write(response: [.make()], urlResponse: urlResponse, to: databaseClient)
        XCTAssertEqual(announcement.position, 100)
    }
}
