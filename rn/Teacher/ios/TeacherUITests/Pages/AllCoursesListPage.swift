//
// Copyright (C) 2017-present Instructure, Inc.
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

import SoGrey
import EarlGrey

class AllCoursesListPage {
    
    // MARK: Singleton
    
    static let sharedInstance = AllCoursesListPage()
    private init() {}
    
    // MARK: Elements
    
    private let coursesTabButton = e.selectBy(id: "tab-bar.courses-btn")
    private let inboxTabButton = e.selectBy(id: "tab-bar.inbox-btn")
    private let profileTabButton = e.selectBy(id: "tab-bar.profile-btn")
    private let stagingTabButton = e.selectBy(id: "tab-bar.staging-btn")
    
    // MARK: - Helpers
    
    private func backButton() -> GREYElementInteraction {
        let backButtonElement = EarlGrey.select(
            elementWithMatcher: grey_allOf([grey_accessibilityLabel("Back"),
                                            grey_accessibilityTrait(UIAccessibilityTraitButton)]))
        return backButtonElement
    }
    
    private func navBarTitleView() -> GREYElementInteraction {
        let titleViewElement = EarlGrey.select(
            elementWithMatcher: grey_allOf([grey_accessibilityLabel("All Courses"),
                                            grey_accessibilityTrait(UIAccessibilityTraitHeader),
                                            grey_accessibilityTrait(UIAccessibilityTraitStaticText)]))
        return titleViewElement
    }
    
    private func courseCard(_ course: Course) -> GREYElementInteraction {
        return e.selectBy(id: course.courseCode)
    }
    
    // MARK: - Assertions
    
    func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        navBarTitleView().assertExists()
        backButton().assertExists()
        coursesTabButton.assertExists()
        inboxTabButton.assertExists()
        profileTabButton.assertExists()
        stagingTabButton.assertExists()
    }
    
    func assertHasCourses(_ courses: [Course], _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        
        for course in courses {
            courseCard(course).assertExists()
        }
    }
    
    // MARK: - UI Actions
    
    func backToCoursesListPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        backButton().tapUntilHidden()
    }
    
}
