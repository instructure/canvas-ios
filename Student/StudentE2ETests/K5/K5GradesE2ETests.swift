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

class K5GradesE2ETests: K5UITestCase {
    func testK5GradesE2E() {
        setUpK5()

        XCTAssertTrue(K5Helper.courseCard(id: "21025").waitUntil(.visible).isVisible)
        K5Helper.grades.hit()
        XCTAssertTrue(K5Helper.gradingPeriodSelectorClosed.waitUntil(.visible).isVisible)
        K5Helper.gradingPeriodSelectorClosed.hit()
        XCTAssertTrue(K5Helper.gradingPeriodSelectorOpen.waitUntil(.visible).isVisible)
        XCTAssertTrue(app.find(labelContaining: "MATH").waitUntil(.visible).isVisible)
        app.find(labelContaining: "MATH").hit()
        XCTAssertTrue(K5Helper.emptyGradesForCourse.waitUntil(.visible).isVisible)
        K5Helper.backButton.hit()
        XCTAssertTrue(app.find(labelContaining: "AUTOMATION 101").waitUntil(.visible).isVisible)
        app.find(labelContaining: "AUTOMATION 101").hit()
        XCTAssertTrue(app.find(label: "Auto Intro").waitUntil(.visible).isVisible)
        XCTAssertTrue(K5Helper.gradedPointsMax(maxPoints: "5").waitUntil(.visible).isVisible)
        XCTAssertTrue(K5Helper.gradedPointsActual(actualPoints: "4").waitUntil(.visible).isVisible)
    }
}
