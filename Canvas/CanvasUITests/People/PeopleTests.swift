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

enum CoursePeople {
    static func person(name: String) -> Element {
        return app.find(label: name)
    }
}

enum PersonContextCard {
    static func emailLabel(_ email: String) -> Element {
        return app.find(label: email)
    }
}

class PeopleTests: CanvasUITests {
    override var user: User? { return .student1 }

    func testCourseUsersAndUserContextCardDisplay() {
        // Dashboard
        Dashboard.courseCard(id: "262").tap()

        // Course Details
        CourseDetails.people.tap()

        // Course People
        XCTAssert(CoursePeople.person(name: "Student One").exists)
        XCTAssert(CoursePeople.person(name: "Student Two").exists)
        CoursePeople.person(name: "Student One").tap()

        // Person Context Card
        XCTAssert(PersonContextCard.emailLabel("ios+student1@instructure.com").exists)
    }
}
