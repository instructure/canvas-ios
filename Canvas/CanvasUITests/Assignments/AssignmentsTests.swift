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

class AssignmentsTests: CanvasUITests {
    func testViewAssignmentAndPreviewAttachment() {
        Dashboard.courseCard(id: "263").waitToExist()
        Dashboard.courseCard(id: "263").tap()

        CourseNavigation.grades.tap()

        GradesList.assignment(id: "1831").tap()

        AssignmentDetails.description("This is assignment one.").waitToExist()
        app.swipeUp()
        AssignmentDetails.link("run.jpg").tap()
        app.find(label: "File", type: .image).waitToExist()
    }
}
