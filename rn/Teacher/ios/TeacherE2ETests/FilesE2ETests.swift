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
import TestsFoundation

class FilesE2ETests: CoreUITestCase {
    func testfilesE2E() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.files.tap()
        FileList.addButton.waitToExist()
        XCTAssertEqual(FileList.file(index: 0).label(), "Published, run.jpg, 133 KB")
        XCTAssertEqual(FileList.file(index: 1).label(), "Published, unfiled, 1 item")
        FileList.file(index: 1).tap()
        XCTAssertEqual(FileList.file(index: 0).label(), "Published, xcode-black.png, 818 KB")
        NavBar.backButton.tap()
        FileList.addButton.tap()
        FileList.addFolderButton.waitToExist()
        FileList.addFileButton.waitToExist()
    }
}
