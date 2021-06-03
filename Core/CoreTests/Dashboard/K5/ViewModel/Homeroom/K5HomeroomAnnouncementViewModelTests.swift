//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

class K5HomeroomAnnouncementViewModelTests: CoreTestCase {

    func testId() {
        let testee = K5HomeroomAnnouncementViewModel(courseName: "c1", title: "c1 title", htmlContent: "", allAnnouncementsRoute: "/courses/c1/announcements")
        XCTAssertEqual(testee.id, "c1c1 title")
    }
}
