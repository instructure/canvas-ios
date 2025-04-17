//
// This file is part of Canvas.
<<<<<<<< HEAD:Core/CoreTests/Features/Courses/SmartSearch/Model/CourseSmartSearchViewAttributesTests.swift
// Copyright (C) 2025-present  Instructure, Inc.
========
// Copyright (C) 2021-present  Instructure, Inc.
>>>>>>>> origin/master:Core/TestsFoundation/UITestCases/K5UITestCase.swift
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

<<<<<<<< HEAD:Core/CoreTests/Features/Courses/SmartSearch/Model/CourseSmartSearchViewAttributesTests.swift
class CourseSmartSearchViewAttributesTests: CoreTestCase {

    func test_default_properties() {
        let testee = CourseSmartSearchViewAttributes.default

        XCTAssertEqual(testee.context, .currentUser)
        XCTAssertNil(testee.accentColor)
    }

    func test_custom_properties() {
        let testee = CourseSmartSearchViewAttributes(
            context: .course("1"),
            color: .red
        )

        XCTAssertEqual(testee.context, .course("1"))
        XCTAssertEqual(testee.accentColor, .red)
        XCTAssertEqual(testee.searchPrompt, String(localized: "Search in this course", bundle: .core))
========
open class K5UITestCase: CoreUITestCase {
    override open var experimentalFeatures: [ExperimentalFeature] { return [ExperimentalFeature.K5Dashboard]}

    open func resetAppStateForK5() {
        app.terminate()
        launch()
        sleep(5)
    }

    open override var user: UITestUser? {
        .readStudentK5
    }

    open func setUpK5() {
        K5Helper.homeroom.waitUntil(.visible)
        resetAppStateForK5()
        app.pullToRefresh()
        K5Helper.homeroom.waitUntil(.visible)
>>>>>>>> origin/master:Core/TestsFoundation/UITestCases/K5UITestCase.swift
    }
}
