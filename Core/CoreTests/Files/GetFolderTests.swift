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

import XCTest
@testable import Core

class GetFolderTests: CoreTestCase {
    func testGetFolders() {
        XCTAssertEqual(GetFolders(context: .course("1")).cacheKey, "courses/1/folders")
        XCTAssertEqual(GetFolders(context: .course("1")).request.context, .course("1"))
        XCTAssertEqual(GetFolders(context: .course("1")).scope, .where(
            #keyPath(Folder.canvasContextID), equals: "course_1",
            orderBy: #keyPath(Folder.name), naturally: true)
        )
        XCTAssertEqual(GetFolders(context: Context(.folder, id: "2")).scope, .where(
            #keyPath(Folder.parentFolderID), equals: "2",
            orderBy: #keyPath(Folder.name), naturally: true)
        )
    }
}
