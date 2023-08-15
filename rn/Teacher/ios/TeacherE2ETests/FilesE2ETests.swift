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

import TestsFoundation

class FilesE2ETests: CoreUITestCase {
    func testfilesE2E() {
        DashboardHelper.courseCard(courseId: "263").hit()
        CourseDetailsHelper.cell(type: .files).hit()
        XCTAssertTrue(FilesHelper.List.addButton.waitUntil(.visible).isVisible)
        XCTAssertEqual(FilesHelper.List.file(index: 0).label, "Published, run.jpg, 133 KB")
        XCTAssertEqual(FilesHelper.List.file(index: 1).label, "Published, unfiled, 1 item")
        FilesHelper.List.file(index: 1).hit()
        XCTAssertEqual(FilesHelper.List.file(index: 0).waitUntil(.visible).label, "Published, xcode-black.png, 818 KB")
        FilesHelper.backButton.hit()
        FilesHelper.List.addButton.hit()
        XCTAssertTrue(FilesHelper.List.addFolderButton.waitUntil(.visible).isVisible)
        XCTAssertTrue(FilesHelper.List.addFileButton.waitUntil(.visible).isVisible)
    }
}
