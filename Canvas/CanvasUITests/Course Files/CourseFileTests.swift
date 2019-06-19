//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import TestsFoundation

enum FilesList {
    static func file(id: String) -> Element {
        return app.find(id: "file-list.file-list-row.cell-file-\(id)")
    }
}

class CourseFileTests: CanvasUITests {
    override var user: User? { return .student1 }

    func testPreviewCourseFile() {
        // Dashboard
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        // Course Details
        CourseNavigation.files.tap()

        // Course Files
        FilesList.file(id: "10528").waitToExist()
        FilesList.file(id: "10528").tap()

        // need be on the next page before checking for image
        sleep(3)
        app.find(type: .image).waitToExist()
    }
}
