//
// Copyright (C) 2016-present Instructure, Inc.
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

import EarlGrey

public class AllCoursesListPage {

    // MARK: Singleton

    public static let sharedInstance = AllCoursesListPage()
    private init() {}

    // MARK: Elements

    private let navBarTitleView = e.selectBy(matchers: [grey_accessibilityID("All Courses"),
                                                        grey_kindOfClass(UINavigationBar.self)])

    private let backButton = e.selectBy(matchers: [grey_accessibilityLabel("Back"),
                                                   grey_kindOfClass(Class.UIAccessibilityBackButtonElement)])

    // MARK: - Helpers

//    private func courseCard(_ course: Course) -> GREYElementInteraction {
//        return e.selectBy(id: course.courseCode)
//    }

    // MARK: - Assertions

    public func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        navBarTitleView.assertExists()
        backButton.assertExists()
    }

//    func assertHasCourses(_ courses: [Course], _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//        
//        for course in courses {
//            courseCard(course).assertExists()
//        }
//    }

    // MARK: - UI Actions

    public func backToCoursesListPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        backButton.tapUntilHidden()
    }
}
